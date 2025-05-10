#!/usr/bin/env bash

warning_msg() {
    echo -e "${YELLOW}Warning: $*${RESET}"
}

log_info() {
    echo -e "${CYAN}[INFO]${RESET} $*"
}

log_debug() {
    [[ "${DEBUG:-0}" == "1" ]] && echo -e "${BLUE}[DEBUG]${RESET} $*" >&2
}

confirm() {
    while true; do
        read -r -p "$(echo -e "${BOLD}${1:-Are you sure? [y/N]:} ${RESET}")" response
        case "$response" in
            [yY]|[nN]) break ;;
            *) echo "Please enter 'y' or 'n'." ;;
        esac
    done
    case "$response" in
        [yY]) true ;;
        *) false ;;
    esac
}

validate_file() {
    [[ -f "$1" ]] || error_exit "File '$1' not found." "$ERROR_INVALID_INPUT"
    [[ -r "$1" ]] || error_exit "File '$1' is not readable." "$ERROR_INVALID_INPUT"
}

validate_dir() {
    [[ -d "$1" ]] || error_exit "Directory '$1' not found." "$ERROR_INVALID_INPUT"
    [[ -x "$1" ]] || error_exit "Directory '$1' is not accessible." "$ERROR_INVALID_INPUT"
}

validate_vcs_status() {
    local vcs
    vcs=$(get_vcs)
    case "$vcs" in
        git)
            validate_git_status
            ;;
        hg)
            validate_hg_status
            ;;
    esac
    return 0
}