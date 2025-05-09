#!/usr/bin/env bash

show_general_help() {
    echo -e "${LTBLUE}${BOLD}Patchouli${RESET}"
    echo -e "A tool for creating and applying patches with automatic VCS detection (Git/Mercurial)."

    echo -e "${YELLOW}${BOLD}Usage:${RESET}"
    echo -e "  $0 [command] [options]\n"

    echo -e "${YELLOW}${BOLD}Commands:${RESET}"
    echo -e "  diff        Create a diff (standard or VCS-based)"
    echo -e "  patch       Apply a patch (standard or VCS-based)"
    echo -e "  help [cmd]  Show this help or command-specific help\n"

    echo -e "${YELLOW}${BOLD}Examples:${RESET}"
    echo -e "  $0 diff file.txt file_new.txt -o changes.patch"
    echo -e "  $0 patch changes.patch -i"
    echo -e "  $0 diff -n 3 -o git.patch    # Last 3 changes in detected VCS"
    echo -e "  $0 patch git.patch          # Apply using detected VCS\n"

    echo -e "${YELLOW}${BOLD}Note:${RESET}"
    echo -e "  The tool automatically detects Git/Mercurial repositories and adjusts behavior accordingly."
    echo -e "  For command-specific options: $0 [command] help"
}

show_help() {
    case "${1:-}" in
        diff) show_diff_help ;;
        patch) show_patch_help ;;
        *) show_general_help ;;
    esac
}

show_version() {
    echo -e "${LTBLUE}${BOLD}Patchouli${RESET}${BOLD} v${VERSION}"
    exit 0
}
