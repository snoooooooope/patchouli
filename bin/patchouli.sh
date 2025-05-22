#!/usr/bin/env bash


# TODO: Make this not a hacky mess

# TODO: Add support for more VCS systems (bzr, svn, etc.)
# TODO: Add support for more configuration options (e.g. --no-color, --no-diff-header, --no-patch-header, etc.)

set -euo pipefail

: "${PREFIX:=/usr/local}"

if [[ "$(dirname "$0")" == "$PREFIX/bin" ]]; then
    BASEDIR="$PREFIX/lib/patchouli"
    CONFDIR="$PREFIX/etc/patchouli"
else
    BASEDIR="$(dirname "$0")/.."
    CONFDIR="$BASEDIR/config"
fi

source "$CONFDIR/defaults.conf" || error_exit "Failed to load default configuration" "$ERROR_CONFIG"

source "$BASEDIR/lib/core/error_handling.sh"
source "$BASEDIR/lib/core/logging.sh"

source "$BASEDIR/lib/vcs/git.sh"
source "$BASEDIR/lib/vcs/hg.sh"

source "$BASEDIR/lib/commands/diff.sh"  
source "$BASEDIR/lib/commands/patch.sh"

source "$BASEDIR/lib/help/general.sh"
source "$BASEDIR/lib/help/diff.sh"
source "$BASEDIR/lib/help/patch.sh"

parse_main_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help|help) show_help; exit 0 ;;
            --version) show_version ;;
            --) shift; COMMAND="$1"; shift; ARGS=("$@"); break ;;
            -*) error_exit "Unknown global option: $1" ;;
            *) COMMAND="$1"; shift; ARGS=("$@"); break ;;
        esac
    done
}

route_command() {
    case "$COMMAND" in
        diff) run_diff "${ARGS[@]}" ;;
        patch) run_patch "${ARGS[@]}" ;;
        help) show_help "${ARGS[0]:-}" ;;
        *) error_exit "Unknown command: $COMMAND. Use '$0 help' for usage." ;;
    esac
}

main() {
    local COMMAND=""
    parse_main_args "$@"
    if [[ -z "$COMMAND" ]]; then
        if command_exists gum; then
            log_info "No command specified. Please choose a command:"
            COMMAND=$(gum choose "diff" "patch" "help")
            if [[ -z "$COMMAND" ]]; then
                error_exit "No command selected." "$ERROR_INVALID_INPUT"
            fi
        else
            show_help
            exit 0 # Exit after showing help if gum is not available
        fi
    fi
    route_command "$@"
}

main "$@"