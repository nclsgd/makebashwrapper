# SPDX-License-Identifier: MIT
# Copyright 2019-2020 Nicolas Godinho <nicolas@godinho.me>

# Inclusion guard
ifndef ._makebashwrapper_defined
override ._makebashwrapper_defined := yes

# Preliminary check: parse .FEATURES to make sure we are on a quite recent GNU
# Make version:
ifneq (3,$(words $(filter oneshell target-specific undefine,$(.FEATURES))))
$(error This version of GNU Make ($(MAKE_VERSION)) seems too old for this GNU Makefile)
endif

# Defining handy Make variables
override .BLANK :=# No character between `:=` and this comment hash sign
# Make quirk: two lines are needed below to set only one newline in the
# .NEWLINE variable:
override define .NEWLINE


endef

# Enable some warnings and disable the GNU Make built-in rules and variables
# (pretty useless for the context of just wrapping Bash script snippets):
MAKEFLAGS += --no-builtin-rules
MAKEFLAGS += --no-builtin-variables
MAKEFLAGS += --warn-undefined-variables

# Do not echo back the content of the target recipes:
.SILENT:

# This setting is the core setting that make this Bash wrapper work.  Use one
# shell session for the whole recipe script:
.ONESHELL:

# Override and undefine any .MAKEBASHWRAPPER_ variables that may be inherited
# from the environment or the Make command line variables or even earlier in
# the Makefile inclusion list:
override undefine .MAKEBASHWRAPPER_PATH
override undefine .MAKEBASHWRAPPER_PRELOAD
override undefine .MAKEBASHWRAPPER_PROLOGUE
override undefine .MAKEBASHWRAPPER_ALWAYS_PRELOAD
override undefine .MAKEBASHWRAPPER_ALWAYS_PROLOGUE
override undefine .MAKEBASHWRAPPER_SELFDOC_MASK_TARGETS

# Get the relative path to the current directory where this present file is
# stored:
override .MAKEBASHWRAPPER_PATH := $(patsubst %/,%,$(dir $(lastword $(MAKEFILE_LIST))))

# It is important that the SHELL and .SHELLFLAGS variables must not be
# inherited from the environment. Override them and set them as requested:
#
# Note regarding SHELL: We cannot use SHELL=bash with the "wrapper.sh" script
# as argument to bash.  There is a special handling of the recipe lines
# parsing if the shell is detected to be a Bourne compatible shell by GNU Make
# (i.e. /bin/sh, /bin/ksh and so on).  In that scenario, leading `-`, `+` and
# `@` characters are trimmed within the recipe content.  This preprocessing may
# break some Bash scripts that we want to inject into the wrapper script.
# Let's stick with the path to "wrapper.sh" file marked as executable.
# For more information, see the GNU Make source code and read function
# `construct_command_argv_internal()` (see the few lines that follow the call
# to the function `is_bourne_compatible_shell` within it).
#
override SHELL := $(.MAKEBASHWRAPPER_PATH)/makebashwrapper.sh
override .SHELLFLAGS = $(foreach ._item,$(.MAKEBASHWRAPPER_PRELOAD),--preload $(._item)) \
                       $(foreach ._item,$(.MAKEBASHWRAPPER_PROLOGUE),--prologue $(._item)) \
                       $(foreach ._item,$(.MAKEBASHWRAPPER_ALWAYS_PRELOAD),--always-preload $(._item)) \
                       $(foreach ._item,$(.MAKEBASHWRAPPER_ALWAYS_PROLOGUE),--always-prologue $(._item)) \
                       --

# Explicitly do *NOT* export SHELL as it may break some scripts or third-party
# programs used in Make recipes since at this current point, SHELL is the path
# to "wrapper.sh" (see above) which is not a real true shell.
unexport SHELL

# Always mark for export the supported environment variables by
# makebashwrapper.sh:
export MAKEBASHWRAPPER_XTRACE MAKEBASHWRAPPER_DONOTHING \
       MAKEBASHWRAPPER_DUMPSCRIPT MAKEBASHWRAPPER_SHELLCHECK


# This variable controls the list of recipes/targets to mask in the automatic
# help messsage.  Target names can be appended to it by other makefiles.
.MAKEBASHWRAPPER_SELFDOC_MASK_TARGETS := ._makebashwrapper_selfdoc_

# Default to this target
.DEFAULT_GOAL := ._makebashwrapper_selfdoc_

.PHONY: ._makebashwrapper_selfdoc_
._makebashwrapper_selfdoc_: override .MAKEBASHWRAPPER_PRELOAD :=# nothing
._makebashwrapper_selfdoc_: override .MAKEBASHWRAPPER_PROLOGUE :=# nothing
._makebashwrapper_selfdoc_: override .MAKEBASHWRAPPER_ALWAYS_PRELOAD :=# nothing
._makebashwrapper_selfdoc_: override .MAKEBASHWRAPPER_ALWAYS_PROLOGUE :=# nothing
# Reminder: MAKEBASHWRAPPER_* environment variables get stripped before recipe.
._makebashwrapper_selfdoc_: override export \
    SELFDOC_EXTRACT_MAKE_TARGETS_AWK_SCRIPT := $(.MAKEBASHWRAPPER_PATH)/extract_make_targets.awk
._makebashwrapper_selfdoc_: override export \
    SELFDOC_MASK_TARGETS = $(.MAKEBASHWRAPPER_SELFDOC_MASK_TARGETS)
._makebashwrapper_selfdoc_:
	#
	# Show the available make targets with their description
	#
	selfdocumentation=''; target_column_width=20
	selfdoc_entry_fmt="  %-$${target_column_width}s  %s"
	# shellcheck disable=SC2059  # format string in printf on purpose
	printf -v reindent_desc_in_selfdoc "\n$$selfdoc_entry_fmt" ' '
	while read -r target_and_escaped_desc; do
	    # Parse the output of the Awk script:
	    read -r target escaped_desc <<< "$$target_and_escaped_desc"
	    eval "desc=$$escaped_desc"  # safe as long as Awk does the escaping
	    # Skip targets to mask (+ potential empty target name):
	    skip=''; for skip_target in '' $${SELFDOC_MASK_TARGETS:-}; do
	        if [[ "$$target" == "$$skip_target" ]]; then skip=1; fi
	    done; if [[ -n "$$skip" ]]; then continue; fi
	    # Reindent descriptions with long target names:
	    if [[ "$${#target}" -gt "$$target_column_width" && -n "$$desc" ]]; then
	        desc=$$'\n'"$$desc"
	    fi
	    # Build the selfdocumentation contents:
	    # shellcheck disable=SC2059  # format string in printf on purpose
	    printf -v selfdoc_entry   "$$selfdoc_entry_fmt\n" \
	        "$$target" "$${desc//$$'\n'/$$reindent_desc_in_selfdoc}"
	    selfdocumentation+="$$selfdoc_entry"
	done <<< "$$( (MAKEBASHWRAPPER_DONOTHING=1 LC_ALL=C $(MAKE) \
	                  -npq ._DUMMY_UNMATCHED_TARGET_ 2>/dev/null || :) \
	        | awk -f "$$SELFDOC_EXTRACT_MAKE_TARGETS_AWK_SCRIPT" | sort -u)"
	if [[ -n "$$selfdocumentation" ]]; then
	    echo -n $$'Available make targets:\n'"$$selfdocumentation"
	else
	    echo >&2 "No target to list (or an error has been encountered during GNU Make database parsing)"
	fi

.PHONY: ._makebashwrapper_shellcheck_all_targets_
# Reminder: MAKEBASHWRAPPER_* environment variables get stripped before recipe.
._makebashwrapper_shellcheck_all_targets_: override export \
    SELFDOC_EXTRACT_MAKE_TARGETS_AWK_SCRIPT := $(.MAKEBASHWRAPPER_PATH)/extract_make_targets.awk
._makebashwrapper_shellcheck_all_targets_: override export \
    SELFDOC_MASK_TARGETS = $(.MAKEBASHWRAPPER_SELFDOC_MASK_TARGETS)
._makebashwrapper_shellcheck_all_targets_:
	#
	# Show the available make targets with their description
	#
	targets_to_check=()
	while read -r target_and_escaped_desc; do
	    # Parse the output of the Awk script:
	    read -r target _ <<< "$$target_and_escaped_desc"
	    # Skip targets to mask (+ potential empty target name):
	    skip=''; for skip_target in '' $${SELFDOC_MASK_TARGETS:-}; do
	        if [[ "$$target" == "$$skip_target" ]]; then skip=1; fi
	    done; if [[ -n "$$skip" ]]; then continue; fi
	    targets_to_check+=("$$target")
	done <<< "$$( (MAKEBASHWRAPPER_DONOTHING=1 LC_ALL=C $(MAKE) \
	                  -npq ._DUMMY_UNMATCHED_TARGET_ 2>/dev/null || :) \
	        | awk -f "$$SELFDOC_EXTRACT_MAKE_TARGETS_AWK_SCRIPT" | sort -u)"
	if [[ "$${#targets_to_check[@]}" -gt 0 ]]; then
	    echo >&2 "Checking targets:" "$${targets_to_check[@]}"
	    exec $(MAKE) --no-print-directory MAKEBASHWRAPPER_SHELLCHECK=1 $${targets_to_check[@]}
	else
	    echo >&2 "No target to check (or an error has been encountered during GNU Make database parsing)"
	fi

endif  # ifndef ._makebashwrapper_defined

# vim: set ft=make ts=4 sw=4 noet ai tw=79:
