# shellcheck shell=bash
# SPDX-License-Identifier: MIT
# Copyright 2019 Nicolas Godinho <nicolas@godinho.me>

# Abandon if run as root:
if [[ "$EUID" -eq 0 ]]; then
    die "For security reasons, please do not run this as root."
fi

# vim: set ft=sh ts=4 sw=4 et ai tw=79:
