# SPDX-License-Identifier: MIT
# Copyright 2019-2020 Nicolas Godinho <nicolas@godinho.me>
include ../init.mk

VALUE_IN_MAKE_SHELL_FUNCTION := $(shell echo OK)

.PHONY: test-make-shell-function
test-make-shell-function: $(eval export VALUE_IN_MAKE_SHELL_FUNCTION)
test-make-shell-function:
	# Test that the Make function `shell` properly works with the Bash wrapper
	# hack.
	if [[ "$$VALUE_IN_MAKE_SHELL_FUNCTION" != 'OK' ]]; then
	    error "FAIL: Could not verify that \$$VALUE_IN_MAKE_SHELL_FUNCTION is set to OK."
	fi

.PHONY: test-messages
test-messages:
	#
	# Unroll a sequence of dummy messages to visually test the message display
	# functions.
	#
	show_debug_messages
	unset_messages_prefix
	debug "This is a debug message."
	say "This is a simple message."
	warn "This is a warning message."
	error "This is an error message."
	success "This is message for success."
	debug "This is a debug message."$$'\n'"With a second line to show proper text alignment."
	say "This is a simple message."$$'\n'"With a second line to show proper text alignment."
	warn "This is a warning message."$$'\n'"With a second line to show proper text alignment."
	error "This is an error message."$$'\n'"With a second line to show proper text alignment."
	success "This is message for success."$$'\n'"With a second line to show proper text alignment."
	set_messages_prefix 'PREFIX'
	debug "This is a debug message with a message prefix."
	say "This is a simple message with a message prefix."
	warn "This is a warning message with a message prefix."
	error "This is an error message with a message prefix."
	success "This is message for success with a message prefix."
	debug "This is a debug message with a message prefix."$$'\n'"With a second line to show proper text alignment."
	say "This is a simple message with a message prefix."$$'\n'"With a second line to show proper text alignment."
	warn "This is a warning message with a message prefix."$$'\n'"With a second line to show proper text alignment."
	error "This is an error message with a message prefix."$$'\n'"With a second line to show proper text alignment."
	success "This is message for success with a message prefix."$$'\n'"With a second line to show proper text alignment."

# vim: set ft=make ts=4 sw=4 noet ai tw=79:
