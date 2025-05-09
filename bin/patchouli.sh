#!/usr/bin/env bash

# This script is the main entry point for the Patchouli tool.
# It parses command-line arguments, loads configuration files, and routes commands to the appropriate functions.

# TODO: Add support for more VCS systems (bzr, svn, etc.)
# TODO: Add support for more configuration options (e.g. --no-color, --no-diff-header, --no-patch-header, etc.)

set -euo pipefail

source "$(dirname "$0")/../lib/core/error_handling.sh"
source "$(dirname "$0")/../lib/core/helpers.sh"
source "$(dirname "$0")/../lib/core/logging.sh"

source "$(dirname "$0")/../config/colors.conf" || error_exit "Failed to load color configuration" $ERROR_CONFIG
source "$(dirname "$0")/../config/defaults.conf" || error_exit "Failed to load default configuration" $ERROR_CONFIG
source "$(dirname "$0")/../config/errors.conf" || error_exit "Failed to load error configuration" $ERROR_CONFIG

source "$(dirname "$0")/../lib/vcs/utils.sh"
source "$(dirname "$0")/../lib/vcs/git.sh"
source "$(dirname "$0")/../lib/vcs/hg.sh"

source "$(dirname "$0")/../lib/commands/diff.sh"  
source "$(dirname "$0")/../lib/commands/patch.sh"

source "$(dirname "$0")/../lib/help/general.sh"
source "$(dirname "$0")/../lib/help/diff.sh"
source "$(dirname "$0")/../lib/help/patch.sh"

parse_main_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help|help) show_help; exit 0 ;;
            --version) show_version ;;
            --) shift; COMMAND="$1"; shift; break ;;
            -*) error_exit "Unknown global option: $1" ;;
            *) COMMAND="$1"; shift; break ;;
        esac
        shift
    done
}

route_command() {
    case "$COMMAND" in
        diff)       run_diff "$@" ;;
        patch)      run_patch "$@" ;;
        help)       show_help "${1:-}" ;;
        *)          error_exit "Unknown command: $COMMAND. Use '$0 help' for usage." ;;
    esac
}

main() {
    local COMMAND=""
    parse_main_args "$@"
    [[ -z "$COMMAND" ]] && show_help
    route_command "$@"
}

main "$@"