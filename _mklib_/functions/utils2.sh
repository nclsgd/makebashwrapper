# shellcheck shell=bash
# SPDX-License-Identifier: MIT
# Copyright 2017-2020 Nicolas Godinho <nicolas@godinho.me>

#
# This file provides somes handy functions (not necessarily written in pure
# Bash unlike "utils.sh").
#


get_nb_random_bytes_as_hexadecimal() {
    head -c "${1:?}" /dev/urandom | hexdump -v -e '1/1 "%x"'
}
readonly -f get_nb_random_bytes_as_hexadecimal


# Hackish function to create an anonymous pipe from a file descriptor number
# TODO: Further tests need to be done.
mkanonfifo() {
    local fdnum="${1:?mkanonfifo <fd-number>}"
    if ! [[ "${fdnum:-}" =~ ^[0-9]+$ ]]; then
        misuse "bad fd number or out of range"
        return 1
    elif { true >&"$fdnum"; } 2<>/dev/null; then
        misuse "fd $fdnum seems already taken"
        return 1
    fi
    local fifofilepath mktempret
    fifofilepath="$(mktemp -p "${TMPDIR:-/tmp}" -u ".anonfifo.XXXXXXX")" \
        && mktempret=$? || mktempret=$?
    if [[ "$mktempret" -ne 0 ]]; then
        misuse "mktemp call failed"
        return 1
    fi
    if ! mkfifo -m 0600 "$fifofilepath"; then
        rm -f "$fifofilepath"
        misuse "mkfifo call on tmpfile failed"
        return 1
    fi
    if ! eval "exec $fdnum<> $(printf '%q' "$fifofilepath")"; then
        rm -f "$fifofilepath"
        misuse "opening the fifo in RW on given FD failed"
        return 1
    fi
    rm -f "$fifofilepath"
}
readonly -f mkanonfifo

# vim: set ft=sh ts=4 sw=4 et ai tw=79:
