#!/usr/bin/env bash

# TODO: clean up and reformat the help text to be more inline with the other help text

show_general_help() {
    echo -e "${LTBLUE}${BOLD}Patchouli${RESET}"
    echo -e "Creating and applying patches with automatic VCS detection (Git/Mercurial)."

    echo -e "${YELLOW}${BOLD}Usage:${RESET}"
    echo -e "  patchouli [command] [options]\n"

    echo -e "${YELLOW}${BOLD}Commands:${RESET}"
    echo -e "  diff        Create a diff"
    echo -e "  patch       Apply a patch"
    echo -e "  [cmd] help , --help , -h For command specific help\n"


    echo -e "${YELLOW}${BOLD}Examples:${RESET}"
    echo -e "  patchouli diff file.txt file_new.txt -o changes.patch"
    echo -e "  patchouli patch changes.patch -i"
    echo -e "  patchouli diff -n 3 -o git.patch    # Last 3 changes in detected VCS"
    echo -e "  patchouli patch git.patch          # Apply using detected VCS\n"

    echo -e "${YELLOW}${BOLD}Note:${RESET}"
    echo -e "  The tool automatically detects Git/Mercurial repositories and adjusts behavior accordingly."
}

show_help() {
    local help_output=""
    case "${1:-}" in
        diff) help_output=$(show_diff_help) ;;
        patch) help_output=$(show_patch_help) ;;
        *) help_output=$(show_general_help) ;;
    esac

    if [[ -t 1 ]] && command_exists gum; then
        echo -e "$help_output" | gum pager
    else
        echo -e "$help_output"
    fi
}

show_version() {
    echo -e "${LTBLUE}${BOLD}Patchouli${RESET}${BOLD} v${VERSION}"
    exit 0
}