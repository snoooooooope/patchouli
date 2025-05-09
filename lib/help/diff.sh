#!/usr/bin/env bash

show_diff_help() {
    echo -e "${LTBLUE}${BOLD}Patchouli${RESET} - ${BOLD}diff${RESET}\n"
    echo -e "${YELLOW}${BOLD}Usage:${RESET}"
    echo -e "  $0 diff [options] <file1> <file2>"
    echo -e "  $0 diff [options] # Uses VCS diff if detected\n"

    echo -e "${YELLOW}${BOLD}Description:${RESET}"
    echo -e "Creates a standard or VCS-specific patch file. Automatically detects"
    echo -e "and uses the appropriate method (standard diff, Git, or Mercurial).\n"

    echo -e "${YELLOW}${BOLD}Options:${RESET}"
    echo -e "  ${ITALIC}-o, --output FILE${RESET}  Specify output patch file (default: changes.patch)"
    echo -e "  ${ITALIC}-n, --num N${RESET}        Number of changes to include (VCS only)"
    echo -e "  ${ITALIC}-s, --since REF${RESET}    Create diff since reference (commit/rev)"
    echo -e "  ${ITALIC}-h, --help${RESET}         Show this help message\n"
    echo -e "  [...standard diff options] Pass standard 'diff' options after '--'."
    echo -e "    Example: '$0 diff -o patch.txt -- -b file1 file2'.\n"

    echo -e "${YELLOW}${BOLD}Examples:${RESET}"
    echo -e "  $0 diff file.txt file_new.txt -u -o changes.patch"
    echo -e "  $0 diff -n 3 -o git.patch # Last 3 Git changes"
    echo -e "  $0 diff -s HEAD~2 -o hg.patch # Since revision"
}

show_vcs_diff_help() {
    local vcs
    vcs=$(get_vcs)
    case "$vcs" in
        git) show_git_diff_help ;;
        hg)  show_hg_diff_help ;;
        *)   show_diff_help ;;
    esac
}

show_git_diff_help() {
    echo -e "${LTBLUE}${BOLD}Patchouli${RESET} - ${BOLD}diff${RESET}\n"
    echo -e "${YELLOW}${BOLD}Usage:${RESET}"
    echo -e "  $0 diff [options] # In a Git repository\n"

    echo -e "${YELLOW}${BOLD}Description:${RESET}"
    echo -e "Creates a Git patch file from changes in the repository.\n"

    echo -e "${YELLOW}${BOLD}Git-specific Options:${RESET}"
    echo -e "  ${ITALIC}-n, --num N${RESET}        Number of commits to include (default: 1)"
    echo -e "  ${ITALIC}-s, --since REF${RESET}    Create diff since reference (commit hash/tag)"
    echo -e "  ${ITALIC}-o, --output FILE${RESET}  Output patch file (default: git.patch)"
    echo -e "  ${ITALIC}-h, --help${RESET}         Show this help message\n"

    echo -e "${YELLOW}${BOLD}Examples:${RESET}"
    echo -e "  $0 diff -n 3 -o git.patch # Last 3 commits"
    echo -e "  $0 diff -s v1.0 -o git.patch # Since tag v1.0"
}

show_hg_diff_help() {
    echo -e "${LTBLUE}${BOLD}Patchouli${RESET} - ${BOLD}diff${RESET}\n"
    echo -e "${YELLOW}${BOLD}Usage:${RESET}"
    echo -e "  $0 diff [options] # In a Mercurial repository\n"

    echo -e "${YELLOW}${BOLD}Description:${RESET}"
    echo -e "Creates a Mercurial patch file from changes in the repository.\n"

    echo -e "${YELLOW}${BOLD}Mercurial-specific Options:${RESET}"
    echo -e "  ${ITALIC}-n, --num N${RESET}        Number of revisions to include (default: 1)"
    echo -e "  ${ITALIC}-s, --since REF${RESET}    Create diff since reference (revision number/tag)"
    echo -e "  ${ITALIC}-o, --output FILE${RESET}  Output patch file (default: hg.patch)"
    echo -e "  ${ITALIC}-h, --help${RESET}         Show this help message\n"

    echo -e "${YELLOW}${BOLD}Examples:${RESET}"
    echo -e "  $0 diff -n 3 -o hg.patch # Last 3 revisions"
    echo -e "  $0 diff -s 1234 -o hg.patch # Since revision 1234"
}
