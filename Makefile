# SPDX-License-Identifier: MIT
# Copyright 2019-2020 Nicolas Godinho <nicolas@godinho.me>
include _mklib_/init.mk

# Example Makefile making use of the the Make Bash wrapper

.PHONY: hello-world
hello-world:
	#
	# Little recipe that says "Hello world!"
	# This is a self-documenting comment that is displayed when the user
	# invokes make without a target.
	#
	say "Hello world!"

# vim: set ft=make ts=4 sw=4 noet ai tw=79:
