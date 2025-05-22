#!/usr/bin/env bash

# TODO: clean up and reformat the help text to be more inline with the other help text

show_patch_help() {
    echo -e "${LTBLUE}${BOLD}Patchouli${RESET} - ${BOLD}patch${RESET}\n"
    echo -e "${YELLOW}${BOLD}Usage:${RESET}"
    echo -e "  patchouli patch <patchfile> [options]\n"

    echo -e "${YELLOW}${BOLD}Description:${RESET}"
    echo -e "Applies a patch file using the appropriate method based on the current VCS (Git, Mercurial) or standard patch utility.\n"

    echo -e "${YELLOW}${BOLD}Options:${RESET}"
    echo -e "  ${ITALIC}-i, --interactive${RESET}  Apply patch interactively"
    echo -e "  ${ITALIC}-3, --3way${RESET}         Attempt 3-way merge if patch fails (Git only)"
    echo -e "  ${ITALIC}-f, --force${RESET}        Force apply even if conflicts exist (Mercurial only)"
    echo -e "  ${ITALIC}-h, --help${RESET}         Show this help message\n"

    echo -e "${YELLOW}${BOLD}Examples:${RESET}"
    echo -e "  patchouli patch changes.patch"
    echo -e "  patchouli patch changes.patch -i"
    echo -e "  patchouli patch git.patch -- -3"
    echo -e "  patchouli patch hg.patch -- -f"
}

show_vcs_patch_help() {
    local vcs
    vcs=$(get_vcs)
    case "$vcs" in
        git) show_git_patch_help ;;
        hg)  show_hg_patch_help ;;
        *)   show_patch_help ;;
    esac
}

show_git_patch_help() {
    echo -e "${LTBLUE}${BOLD}Patchouli${RESET} - ${BOLD}patch${RESET}\n"
    echo -e "${YELLOW}${BOLD}Usage:${RESET}"
    echo -e "  patchouli patch <patchfile> [options] # In a Git repository\n"

    echo -e "${YELLOW}${BOLD}Description:${RESET}"
    echo -e "Applies a Git patch file using either 'git apply' or 'git am'.\n"

    echo -e "${YELLOW}${BOLD}Git-specific Options:${RESET}"
    echo -e "  ${ITALIC}-3, --3way${RESET}         Attempt 3-way merge if patch fails"
    echo -e "  ${ITALIC}-i, --interactive${RESET}  Apply patch interactively"
    echo -e "  ${ITALIC}-h, --help${RESET}         Show this help message\n"

    echo -e "${YELLOW}${BOLD}Examples:${RESET}"
    echo -e "  patchouli patch git.patch       # Standard apply"
    echo -e "  patchouli patch git.patch -3    # With 3-way merge"
    echo -e "  patchouli patch git.patch -i    # Interactive mode"
}

show_hg_patch_help() {
    echo -e "${LTBLUE}${BOLD}Patchouli${RESET} - ${BOLD}patch${RESET}\n"
    echo -e "${YELLOW}${BOLD}Usage:${RESET}"
    echo -e "  patchouli patch <patchfile> [options] # In a Mercurial repository\n"

    echo -e "${YELLOW}${BOLD}Description:${RESET}"
    echo -e "Applies a Mercurial patch file using 'hg import'.\n"

    echo -e "${YELLOW}${BOLD}Mercurial-specific Options:${RESET}"
    echo -e "  ${ITALIC}-f, --force${RESET}        Force apply even if conflicts exist"
    echo -e "  ${ITALIC}-h, --help${RESET}         Show this help message\n"

    echo -e "${YELLOW}${BOLD}Examples:${RESET}"
    echo -e "  patchouli patch hg.patch       # Standard import"
    echo -e "  patchouli patch hg.patch -f    # Force import"
}