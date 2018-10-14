# SPDX-License-Identifier: MIT
# Copyright 2019-2020 Nicolas Godinho <nicolas@godinho.me>

# Force wipe all Make variables beginning with `._` as we specifically use this
# prefix to indicate internal and private Make variables (the leading dot
# prevents these vairables from polluting the child process environments):
$(foreach ._var,$(filter ._%,$(.VARIABLES)),$(eval override undefine $(._var)))

# Get the path to the current "_mklib_" directory and store it in a Make
# variable to be used everyplace contents from this directory is to be used.
# Note: The line below obviously implies that this current file must be sitting
# at the root of the "_mklib_" directory:
override ._mklib_ := $(patsubst %/,%,$(dir $(lastword $(MAKEFILE_LIST))))

# The core GNU Make directives to wrap the recipes into rich-featured Bash
# scripts:
include $(._mklib_)/wrapper/makebashwrapper.mk

# The utilities and common functions expected in all targets using this
# Make/Bash wrapper:
.MAKEBASHWRAPPER_ALWAYS_PRELOAD += $(._mklib_)/functions/utils.sh
.MAKEBASHWRAPPER_ALWAYS_PROLOGUE += $(._mklib_)/prologues/utils.sh
# These variables below need to be exported for the prologue just above:
export debug trace trace_fd

# The function expected only in the recipes:
.MAKEBASHWRAPPER_PRELOAD += $(._mklib_)/functions/acquire_sudo_session.sh

# vim: set ft=make noet ts=4 sw=4 ai tw=79:
