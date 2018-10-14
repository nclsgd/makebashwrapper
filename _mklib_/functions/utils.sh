# shellcheck shell=bash
# SPDX-License-Identifier: MIT
# Copyright 2017-2020 Nicolas Godinho <nicolas@godinho.me>

#
# This file provides my kind of "standard library" set of functions written in
# pure Bash.  Those functions are meant to write fancy messages, handle
# human-readable "boolean-string" values, provide xtrace message with context
# information, manage a stack of function callbacks to be invoked upon command
# interpreter termination, etc.
#

# TODO List:
#   - Write a function to test the current version of Bash and invoke it before
#     loading all the functions contained in this file.
#   - Add proper documentation comment on top of each function.
#   - Write common tests.
#   - Test the behavior of these functions with earlier Bash version (it may
#     work with Bash 4.0...).

# Bash >= 4.3 is required

linebreak() {
    echo >&2
}
readonly -f linebreak

misuse() {
    local __xtrace_disabled_just_for_this_function__="${-//[^x]}"; set +x
    echo >&2 "${FUNCNAME[1]:-<global-scope>}:$(printf ' %s' "$@")"
    # shellcheck disable=SC2015  # hack to prevent function from returning !0
    [[ "${__xtrace_disabled_just_for_this_function__}" ]] && set -x || :
}
readonly -f misuse

# ---

show_debug_messages() {
    declare -g +x __show_debug_messages__=yes   # not meant to be exported
}
readonly -f show_debug_messages

hide_debug_messages() {
    declare -g +x __show_debug_messages__=no   # not meant to be exported
}
readonly -f hide_debug_messages

# ---

set_messages_prefix() {
    local __xtrace_disabled_just_for_this_function__="${-//[^x]}"; set +x
    declare -g +x __messages_prefix__ __messages_prefix_color__
    if [[ -n "${1:-}" ]]; then
        __messages_prefix__="[${1:?}]"
        __messages_prefix_color__=$'\e[0;7m[\e[1m'${1:?}$'\e[0;7m]\e[0m'
    else
        unset_messages_prefix
    fi
    # shellcheck disable=SC2015  # hack to prevent function from returning !0
    [[ "${__xtrace_disabled_just_for_this_function__}" ]] && set -x || :
}
readonly -f set_messages_prefix

unset_messages_prefix() {
    local __xtrace_disabled_just_for_this_function__="${-//[^x]}"; set +x
    declare -g +x __messages_prefix__='' __messages_prefix_color__=''
    # shellcheck disable=SC2015  # hack to prevent function from returning !0
    [[ "${__xtrace_disabled_just_for_this_function__}" ]] && set -x || :
}
readonly -f unset_messages_prefix

# ---

debug() {
    local __xtrace_disabled_just_for_this_function__="${-//[^x]}"; set +x
    if [[ -z "${*:+ok}" ]]; then
        misuse "called without text to display"
        [[ "${__xtrace_disabled_just_for_this_function__}" ]] && set -x
        return 1
    fi
    if yesno "${__show_debug_messages__:-no}"; then
        local text prefix lines
        text="$(printf '%s ' "$@")"; text="${text::-1}"
        mapfile -t lines <<< "$text"
        if [[ -t 2 && -z "${NO_COLOR:-}" ]]; then
            prefix="${__messages_prefix_color__:-}"
            text=$' \e[0;1;35m::\e[0m '"$(printf $'\e[0;3m%s\e[0m\n' "${lines[@]}")"
            echo >&2 "${prefix}${text//$'\n'/$'\n'${prefix}'    '}"
        else
            prefix="${__messages_prefix__:-}${__messages_prefix__:+ }"
            text="DEBUG: $(printf '%s\n' "${lines[@]}")"
            echo >&2 "${prefix}${text//$'\n'/$'\n'${prefix}'       '}"
        fi
    fi
    # shellcheck disable=SC2015  # hack to prevent function from returning !0
    [[ "${__xtrace_disabled_just_for_this_function__}" ]] && set -x || :
}
readonly -f debug

say() {
    local __xtrace_disabled_just_for_this_function__="${-//[^x]}"; set +x
    if [[ -z "${*:+ok}" ]]; then
        misuse "called without text to display"
        [[ "${__xtrace_disabled_just_for_this_function__}" ]] && set -x
        return 1
    fi
    local text prefix lines
    text="$(printf '%s ' "$@")"; text="${text::-1}"
    mapfile -t lines <<< "$text"
    if [[ -t 2 && -z "${NO_COLOR:-}" ]]; then
        prefix="${__messages_prefix_color__:-}"
        text=$' \e[0;1;34m->\e[0m '"$(printf $'\e[0m%s\e[0m\n' "${lines[@]}")"
        echo >&2 "${prefix}${text//$'\n'/$'\n'${prefix}'    '}"
    else
        prefix="${__messages_prefix__:-}${__messages_prefix__:+ }"
        text="INFO: $(printf '%s\n' "${lines[@]}")"
        echo >&2 "${prefix}${text//$'\n'/$'\n'${prefix}'      '}"
    fi
    # shellcheck disable=SC2015  # hack to prevent function from returning !0
    [[ "${__xtrace_disabled_just_for_this_function__}" ]] && set -x || :
}
readonly -f say

warn() {
    local __xtrace_disabled_just_for_this_function__="${-//[^x]}"; set +x
    if [[ -z "${*:+ok}" ]]; then
        misuse "called without text to display"
        [[ "${__xtrace_disabled_just_for_this_function__}" ]] && set -x
        return 1
    fi
    local text prefix lines
    text="$(printf '%s ' "$@")"; text="${text::-1}"
    mapfile -t lines <<< "$text"
    if [[ -t 2 && -z "${NO_COLOR:-}" ]]; then
        prefix="${__messages_prefix_color__:-}"
        text=$' \e[0;1;33m!!\e[0m '"$(printf $'\e[1m%s\e[0m\n' "${lines[@]}")"
        echo >&2 "${prefix}${text//$'\n'/$'\n'${prefix}'    '}"
    else
        prefix="${__messages_prefix__:-}${__messages_prefix__:+ }"
        text="WARNING: $(printf '%s\n' "${lines[@]}")"
        echo >&2 "${prefix}${text//$'\n'/$'\n'${prefix}'         '}"
    fi
    # shellcheck disable=SC2015  # hack to prevent function from returning !0
    [[ "${__xtrace_disabled_just_for_this_function__}" ]] && set -x || :
}
readonly -f warn

error() {
    local __xtrace_disabled_just_for_this_function__="${-//[^x]}"; set +x
    if [[ -z "${*:+ok}" ]]; then
        misuse "called without text to display"
        [[ "${__xtrace_disabled_just_for_this_function__}" ]] && set -x
        return 1
    fi
    local text prefix lines
    text="$(printf '%s ' "$@")"; text="${text::-1}"
    mapfile -t lines <<< "$text"
    if [[ -t 2 && -z "${NO_COLOR:-}" ]]; then
        prefix="${__messages_prefix_color__:-}"
        text=$' \e[0;1;31m##\e[0m '"$(printf $'\e[1m%s\e[0m\n' "${lines[@]}")"
        echo >&2 "${prefix}${text//$'\n'/$'\n'${prefix}'    '}"
    else
        prefix="${__messages_prefix__:-}${__messages_prefix__:+ }"
        text="ERROR: $(printf '%s\n' "${lines[@]}")"
        echo >&2 "${prefix}${text//$'\n'/$'\n'${prefix}'       '}"
    fi
    # shellcheck disable=SC2015  # hack to prevent function from returning !0
    [[ "${__xtrace_disabled_just_for_this_function__}" ]] && set -x || :
}
readonly -f error

success() {
    local __xtrace_disabled_just_for_this_function__="${-//[^x]}"; set +x
    if [[ -z "${*:+ok}" ]]; then
        misuse "called without text to display"
        [[ "${__xtrace_disabled_just_for_this_function__}" ]] && set -x
        return 1
    fi
    local text prefix lines
    text="$(printf '%s ' "$@")"; text="${text::-1}"
    mapfile -t lines <<< "$text"
    if [[ -t 2 && -z "${NO_COLOR:-}" ]]; then
        prefix="${__messages_prefix_color__:-}"
        text=$' \e[0;1;32m**\e[0m '"$(printf $'\e[0m%s\e[0m\n' "${lines[@]}")"
        echo >&2 "${prefix}${text//$'\n'/$'\n'${prefix}'    '}"
    else
        prefix="${__messages_prefix__:-}${__messages_prefix__:+ }"
        text="SUCCESS: $(printf '%s\n' "${lines[@]}")"
        echo >&2 "${prefix}${text//$'\n'/$'\n'${prefix}'         '}"
    fi
    # shellcheck disable=SC2015  # hack to prevent function from returning !0
    [[ "${__xtrace_disabled_just_for_this_function__}" ]] && set -x || :
}
readonly -f success

# Shortcut functions to raise an error message and exit the whole script:
die() {
    die2 1 "$@"
}
readonly -f die

die2() {
    local __xtrace_disabled_just_for_this_function__="${-//[^x]}"; set +x
    local exitcode="${1:?die2() requires an exit code as first argument}"
    shift
    if [[ "$exitcode" -eq 0 ]]; then
        misuse 'exit code should not be zero as this function announces an error'
        exitcode=255
    fi
    if [[ -z "${*:+ok}" ]]; then
        error "Fatal error occured for an unknown reason. :("
    else
        error "$@"
    fi
    [[ "${__xtrace_disabled_just_for_this_function__}" ]] && set -x
    exit "$exitcode"
}
readonly -f die2

# This function formats a question as a string to be fed to the `read' builtin
# prompt option (-p). Example of proper usage below:
#
#   question="$(format_question_prompt "Why did the chicken cross the road?")"
#   read [-r] [-e] [-t TIMEOUT] -p "$question" answer || { \
#           answer='default answer if read fails'; linebreak; false; }
#
# Note: Failure to read can occur upon timeout or bad input file descriptor.
format_question_prompt() {
    local __xtrace_disabled_just_for_this_function__="${-//[^x]}"; set +x
    if [[ -z "${*:+ok}" ]]; then
        misuse "called without text to display"
        [[ "${__xtrace_disabled_just_for_this_function__}" ]] && set -x
        return 1
    fi
    local text prefix lines
    text="$(printf '%s ' "$@")"; text="${text::-1}"
    mapfile -t lines <<< "$text"
    if [[ -t 2 && -z "${NO_COLOR:-}" ]]; then
        prefix="${__messages_prefix_color__:-}"
        text=$' \e[0;1;36m??\e[0m '"$(printf $'\e[0m%s\e[0m\n' "${lines[@]}")"
        echo -n "${prefix}${text//$'\n'/$'\n'${prefix}'    '} "
    else
        prefix="${__messages_prefix__:-}${__messages_prefix__:+ }"
        text="QUESTION: $(printf '%s\n' "${lines[@]}")"
        echo -n "${prefix}${text//$'\n'/$'\n'${prefix}'          '} "
    fi
    # shellcheck disable=SC2015  # hack to prevent function from returning !0
    [[ "${__xtrace_disabled_just_for_this_function__}" ]] && set -x || :
}
readonly -f format_question_prompt

# ---

# Fancy xtrace features initialization
set_fancy_xtrace_prompt_indicator() {
    local __xtrace_disabled_just_for_this_function__="${-//[^x]}"; set +x
    local xtrace_fd="${1:-}"
    declare -g +x BASH_XTRACEFD  # global but not exported
    [[ -n "${xtrace_fd:-}" ]] && BASH_XTRACEFD="${xtrace_fd}"
    if [[ -t "${xtrace_fd:-2}" && -z "${NO_COLOR:-}" ]]; then
        PS4=$'+\e[0;36m${BASH_SOURCE[0]}\e[0m:\e[0;35m${LINENO}${FUNCNAME[0]:+\e[0m:\e[0;1;34m${FUNCNAME[0]}()}\e[0m: '
    else
        PS4='+${BASH_SOURCE[0]}:${LINENO}${FUNCNAME[0]:+:${FUNCNAME[0]}()}: '
    fi
    # shellcheck disable=SC2015  # hack to prevent function from returning !0
    [[ "${__xtrace_disabled_just_for_this_function__}" ]] && set -x || :
}
readonly -f set_fancy_xtrace_prompt_indicator

# ---

# Inspired from OpenRC yesno function (but without the part where it
# dereferences the value if that one is not understandable as a
# human-comprehensive boolean value):
yesno() {
    local __xtrace_disabled_just_for_this_function__="${-//[^x]}"; set +x
    [[ "$#" -eq 0 ]] && { misuse "missing boolean value argument"; exit 255; }
    [[ "$#" -gt 1 ]] && { misuse "too many arguments"; exit 255; }
    case "${1,,}" in
        y|yes|true|on|1)
            [[ "${__xtrace_disabled_just_for_this_function__}" ]] && set -x
            return 0 ;;
        n|no|false|off|0)
            [[ "${__xtrace_disabled_just_for_this_function__}" ]] && set -x
            return 1 ;;
        '')
            misuse "Fatal error: empty string cannot be evaluated as a boolean (must be either: y(es)/n(o), true/false, on/off, 1/0). Exiting shell process."
            exit 255 ;;
        *)
            misuse "Fatal error: \"$1\" is not a boolean (must be either: y(es)/n(o), true/false, on/off, 1/0). Exiting shell process."
            exit 255 ;;
    esac
}
readonly -f yesno

assert_yesno() {
    local __xtrace_disabled_just_for_this_function__="${-//[^x]}"; set +x
    [[ "$#" -eq 0 ]] && { misuse "missing boolean value argument"; return 255; }
    [[ "$#" -gt 1 ]] && { misuse "too many arguments"; return 255; }
    case "${1,,}" in
        y|yes|true|on|1|n|no|false|off|0)
            [[ "${__xtrace_disabled_just_for_this_function__}" ]] && set -x
            return 0 ;;
        '')
            misuse "empty string cannot be evaluated as a boolean (must be either: y(es)/n(o), true/false, on/off, 1/0)"
            [[ "${__xtrace_disabled_just_for_this_function__}" ]] && set -x
            return 1 ;;
        *)
            misuse "\"$1\" is not a boolean (must be either: y(es)/n(o), true/false, on/off, 1/0)"
            [[ "${__xtrace_disabled_just_for_this_function__}" ]] && set -x
            return 1 ;;
    esac
}
readonly -f assert_yesno

# ---

initialize_debug_and_trace_prologue() {
    declare -g __debug_and_trace_already_initialized__
    if [[ -n "${__debug_and_trace_already_initialized__:-}" ]]; then
        misuse "this prologue is not meant to be invoked twice within the same session"
        return 1
    fi
    readonly __debug_and_trace_already_initialized__=1

    # Sets the messages prefix if any:
    if [[ -n "${MESSAGES_PREFIX:-}" ]]; then set_messages_prefix "$MESSAGES_PREFIX"; fi

    # debug and trace are global variables (but can still be exported)
    declare -g debug trace
    # Sanity checks on global variables (and default value setting if unset/empty):
    assert_yesno "${debug:=no}" || die "Not a boolean variable: debug"
    assert_yesno "${trace:=no}" || die "Not a boolean variable: trace"
    if ! [[ "${trace_fd:=}" =~ ^(|0|[1-9][0-9]*)$ ]]; then
        die "Variable \"trace_fd\" must be an integer indicating a valid writable file descriptor."
    elif [[ -n "$trace_fd" ]] && ! { true >&"$trace_fd"; } 2>/dev/null; then
        die "Trace output file descriptor (trace_fd=$trace_fd) seems invalid."
    fi

    # Build an interesting logging trace:
    local caller_file='' caller_lineno='' caller_info=''
    read -r caller_lineno caller_file <<< "$(caller || :)"
    if [[ -n "$caller_file" ]]; then
        caller_info="$caller_file${caller_lineno:+ (line $caller_lineno)}"
    fi
    local startup_log_trace=''
    # shellcheck disable=SC2046  # compgen subshell is to be word-expanded
    printf -v startup_log_trace "%s\n" \
        "Current environment debugging trace:" \
        "  Initialization called from: ${caller_info:-<undetermined>}" \
        "  Timestamp: $(printf '%(%Y-%m-%d %H:%M:%S %Z)T' || echo '<undetermined>')" \
        "  Bash PID: ${BASHPID:-<undefined>}" \
        "  Bash version: ${BASH_VERSION:-<undefined>}${BASH_VERSINFO[5]:+ (${BASH_VERSINFO[5]})}" \
        "  Bash options: ${-:-<undefined>}" \
        "  Bash optional additional behaviors: ${BASHOPTS:-<undefined>}" \
        "  Environment variables:$(printf ' %s' $(compgen -A export))"
    startup_log_trace="${startup_log_trace%$'\n'}"  # strip trailing newline

    # Handle debug mode:
    if yesno "$debug"; then show_debug_messages; else hide_debug_messages; fi

    # And handle trace mode...
    set_fancy_xtrace_prompt_indicator "$trace_fd"
    if yesno "$trace"; then
        debug "$startup_log_trace"
        # Note: Since the startup log trace may not have been logged in the
        # case debug was not enabled, we do here a little processing to still
        # log it in the trace output in order not to lose that debug trace:
        if ! yesno "$debug" || [[ "${trace_fd:-2}" -ne 2 ]]; then
            set -x
            : "$startup_log_trace"  # will make it end up in the trace log
        else
            set -x
        fi
    fi
}
readonly -f initialize_debug_and_trace_prologue

# ---

# Simple function to check if a given item (first argument of the function
# call) is contained in a list of items (i.e. an unfolded array) passed as next
# arguments.
contains() {
    local __xtrace_disabled_just_for_this_function__="${-//[^x]}"; set +x
    local elt="${1:?contains() requires an element to search as first arg}"
    shift
    local x
    for x in "$@"; do
        if [[ "$x" = "$elt" ]]; then
            [[ "${__xtrace_disabled_just_for_this_function__}" ]] && set -x
            return 0
        fi
    done
    [[ "${__xtrace_disabled_just_for_this_function__}" ]] && set -x
    return 1
}
readonly -f contains

# ---

# Function hacking around timeout option of the `read' builting to create a
# pure-Bash sleep function that does not fork (which may be useful in some
# sketchy scenarios where signal management is important).
non_forking_sleep() {
    local __xtrace_disabled_just_for_this_function__="${-//[^x]}"; set +x
    if [[ "$#" -ne 1 ]]; then
        misuse "bad number of arguments"
        [[ "${__xtrace_disabled_just_for_this_function__}" ]] && set -x
        return 1
    elif [[ "${1,,}" == 'inf' ]]; then
        read -r _ <> <(:) || :
    elif [[ -n "$1" && "$1" =~ ^[0-9]*(\.[0-9]+)?$ ]]; then
        read -r -t "$1" _ <> <(:) || :
    else
        misuse "argument is neither a number nor \"inf\""
        [[ "${__xtrace_disabled_just_for_this_function__}" ]] && set -x
        return 1
    fi
    # shellcheck disable=SC2015  # hack to prevent function from returning !0
    [[ "${__xtrace_disabled_just_for_this_function__}" ]] && set -x || :
}
readonly -f non_forking_sleep

# ---

# Set of functions to manage a stack of callbacks to be executed on exit of the
# main program. This set of functions relies on the Bash EXIT trap. Therefore
# the EXIT trap should not be fiddled with when the program relies on those
# functions.
__atexit_trap__() {
    local callback
    declare -g +x __atexit_callbacks__
    for callback in "${__atexit_callbacks__[@]}"; do
        if ! eval "${callback:-}"; then
            misuse 'An atexit trap callback returned with failure. Proceeding...'
            continue
        fi
    done
}
readonly -f __atexit_trap__

atexit_push() {
    local __xtrace_disabled_just_for_this_function__="${-//[^x]}"; set +x
    trap __atexit_trap__ EXIT  # Ensure the trap is always set for exit
    if ! [[ "$#" -eq 1 && -n "${1:-}" ]]; then
        misuse 'usage: atexit_push <callback>'
        [[ "${__xtrace_disabled_just_for_this_function__}" ]] && set -x
        return 1
    fi
    declare -g +x __atexit_callbacks__
    __atexit_callbacks__=("$1" "${__atexit_callbacks__[@]}")
    [[ "${__xtrace_disabled_just_for_this_function__}" ]] && set -x
    : Callbacks on exit: "${__atexit_callbacks__[@]}"  # for debug log
}
readonly -f atexit_push

atexit_pop() {
    local __xtrace_disabled_just_for_this_function__="${-//[^x]}"; set +x
    trap __atexit_trap__ EXIT  # Ensure the trap is always set for exit
    if [[ "$#" -ne 0 ]]; then
        misuse 'usage: atexit_pop'
        [[ "${__xtrace_disabled_just_for_this_function__}" ]] && set -x
        return 1
    fi
    declare -g +x __atexit_callbacks__
    if [[ "${#__atexit_callbacks__[@]}" -le 1 ]]; then
        __atexit_callbacks__=()
    else
        __atexit_callbacks__=("${__atexit_callbacks__[@]:1}")
    fi
    [[ "${__xtrace_disabled_just_for_this_function__}" ]] && set -x
    : Callbacks on exit: "${__atexit_callbacks__[@]}"  # for debug log
}
readonly -f atexit_pop

# vim: set ft=sh ts=4 sw=4 et ai tw=79:
