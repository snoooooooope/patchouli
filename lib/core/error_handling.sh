#!/usr/bin/env bash

ERROR_GENERAL=1
ERROR_INVALID_INPUT=2
ERROR_VCS=3

error_exit() {
    local exit_code=${2:-$ERROR_GENERAL}
    echo -e "${RED}Error: $1${RESET}" >&2
    exit "$exit_code"
}

warning_msg() {
    echo -e "${YELLOW}Warning: $*${RESET}"
}

validate_vcs_status() {
    local vcs
    vcs=$(get_vcs)
    case "$vcs" in
        git)
            if ! git diff-index --quiet HEAD --; then
                warning_msg "Git working directory is not clean. Consider committing or stashing your changes before patching."
                return $ERROR_VCS
            fi
            ;;
        hg)
            if hg status | grep -q .; then
                warning_msg "Mercurial working directory is not clean. Consider committing or stashing your changes before patching."
                return $ERROR_VCS
            fi
            ;;
    esac
    return 0
}
