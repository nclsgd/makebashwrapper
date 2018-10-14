# shellcheck shell=bash
# SPDX-License-Identifier: MIT
# Copyright 2019-2020 Nicolas Godinho <nicolas@godinho.me>

acquire_sudo_session() {
    say "Acquiring super-user privileges via sudo and keep this sudo session alive..."
    # NOTE: `sudo -v` just keep validating the current sudo "session" with
    # executing any commmand:
    if ! command sudo -v; then
        error "Could not acquire super-user privileges via sudo."
        return 1
    fi
    local keepalive_coproc keepalive_coproc_PID
    # shellcheck disable=SC2034  # because keepalive_coproc var is not used
    coproc keepalive_coproc {
        # Closing stdin and stdout as this coproc does not interact with its
        # parent process:
        exec <&- >&-
        set_messages_prefix "sudo session keep-alive coprocess"
        while command sudo -v -S <&- &>/dev/null; do non_forking_sleep 60; done
        die "Exiting due to \"sudo -v\" returning non-zero. Does sudo allow a timeout of at least 1 minute?"
    }
    non_forking_sleep 0.1  # wait until coproc does one `sudo -v ...' call
    # NOTE: `kill -0` does nothing to the process but allows us to check if the
    # given PID is actually running.
    if ! kill -0 "${keepalive_coproc_PID:-}"; then
        error "Sudo session keep-alive coprocess does not seem to work."
        return 1
    else
        # sets a trap to kill this coprocess on exit
        local kill_keepalive_coproc_snippet
        printf -v kill_keepalive_coproc_snippet '%s\n' \
            "if kill '$keepalive_coproc_PID'; then" \
            "  debug 'Sudo session keep-alive coprocess (PID=$keepalive_coproc_PID) terminated'" \
            "else" \
            "  warn 'Error while terminating the sudo session keep-alive coprocess (PID=$keepalive_coproc_PID)'" \
            "fi"
        atexit_push "$kill_keepalive_coproc_snippet"
    fi
    debug "Sudo session keep-alive coprocess is running under PID: $keepalive_coproc_PID"
}
readonly -f acquire_sudo_session

# vim: set ft=sh ts=4 sw=4 et ai tw=79:
