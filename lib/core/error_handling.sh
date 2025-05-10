#!/usr/bin/env bash

error_exit() {
    local message="$1"
    local exit_code=${2:-$ERROR_GENERAL}
    local prefix
    
    case $exit_code in
        "$ERROR_INVALID_INPUT") prefix="Invalid input";;
        "$ERROR_VCS") prefix="Version control error";;
        "$ERROR_MISSING_DEP") prefix="Missing dependency";;
        "$ERROR_CONFIG") prefix="Configuration error";;
        "$ERROR_PERMISSION") prefix="Permission denied";;
        "$ERROR_IO") prefix="I/O operation failed";;
        *) prefix="Error";;
    esac

    echo -e "${RED}${BOLD}$prefix:${RESET} $message" >&2
    exit "$exit_code"
}

validate_vcs_status() {
    local vcs
    if ! vcs=$(get_vcs); then
        error_exit "Could not detect version control system" "$ERROR_VCS"
    fi

    case "$vcs" in
        git)
            if ! git diff-index --quiet HEAD -- 2>/dev/null; then
                warning_msg "Uncommitted changes detected in Git repository"
                return "$ERROR_VCS"
            fi
            ;;
        hg)
            if ! hg status --quiet 2>/dev/null; then
                warning_msg "Uncommitted changes detected in Mercurial repository"
                return "$ERROR_VCS"
            fi
            ;;
    esac
    return 0
}
