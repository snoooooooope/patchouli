#!/usr/bin/env bash

show_diff_help() {
    echo -e "${LTBLUE}${BOLD}Patchouli${RESET} - ${BOLD}diff${RESET}\n"
    echo -e "${YELLOW}${BOLD}Usage:${RESET}"
    echo -e "  patchouli diff [options] <file1> <file2>\n"

    echo -e "${YELLOW}${BOLD}Description:${RESET}"
    echo -e "Creates a standard patch file\n"

    echo -e "${YELLOW}${BOLD}Options:${RESET}"
    echo -e "  ${ITALIC}-u, --unified${RESET}              # Output unified diff format"
    echo -e "  ${ITALIC}-c, --context${RESET}              # Output context diff format"
    echo -e "  ${ITALIC}-N, --new-file${RESET}             # Treat absent files as empty"
    echo -e "  ${ITALIC}-r, --recursive${RESET}            # Recursively compare subdirectories"
    echo -e "  ${ITALIC}-i, --ignore-case${RESET}          # Ignore case differences in file contents"
    echo -e "  ${ITALIC}-w, --ignore-all-space${RESET}     # Ignore all whitespace changes"
    echo -e "  ${ITALIC}-b, --ignore-space-change${RESET}  # Ignore changes in whitespace amount"
    echo -e "  ${ITALIC}-B, --ignore-blank-lines${RESET}   # Ignore changes inserting/deleting blank lines"
    echo -e "  ${ITALIC}-o, --output <file>${RESET}        # Specify output patch file (default: changes.patch)"
    echo -e "  ${ITALIC}-h, --help${RESET}                 # Show this help message\n"

    echo -e "${YELLOW}${BOLD}Examples:${RESET}\n"
    echo -e "  ${LTBLUE}${BOLD}patchouli${RESET} diff file1.txt file2.txt       # Basic file comparison"
    echo -e "  ${LTBLUE}${BOLD}patchouli${RESET} diff -u old.c new.c -o changes.patch       # Unified diff format with output file"
    echo -e "  ${LTBLUE}${BOLD}patchouli${RESET} diff -r dir1/ dir2/        # Recursively compare dir1/ and dir2/\n"

    echo -e "${YELLOW}${BOLD}Notes:${RESET}"
    echo -e "    - All of the usual diff options are supported, but are far too many to list here."
    echo -e "    - See the diff(1) man page for more information.\n"
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
    echo -e "${LTBLUE}${BOLD}Patchouli${RESET} - ${BOLD}git diff${RESET}\n"
    echo -e "${YELLOW}${BOLD}Usage:${RESET}"
    echo -e "  ${LTBLUE}${BOLD}patchouli${RESET} diff [options]\n"

    echo -e "${YELLOW}${BOLD}Description:${RESET}"
    echo -e "Creates a Git patch file from changes in the repository.\n"

    echo -e "${YELLOW}${BOLD}Git-specific Options:${RESET}"
    echo -e "  ${ITALIC}-n, --num N${RESET}              # Number of commits to include (default: 1)"
    echo -e "  ${ITALIC}-s, --since <rev>${RESET}        # Create diff since reference (commit hash/tag)"
    echo -e "  ${ITALIC}-o, --output <file>${RESET}      # Output patch file (default: git.patch)"
    echo -e "  ${ITALIC}-u, --unified${RESET}            # Output unified diff format"
    echo -e "  ${ITALIC}-c, --context${RESET}            # Output context diff format"
    echo -e "  ${ITALIC}-h, --help${RESET}               # Show this help message\n"

    echo -e "${YELLOW}${BOLD}Examples:${RESET}\n"
    echo -e "  ${LTBLUE}${BOLD}patchouli${RESET} diff text.txt      # Compare text.txt to last commit"
    echo -e "  ${LTBLUE}${BOLD}patchouli${RESET} diff abc123 def456     # Compare commit abc123 to def456\n"

    echo -e "${YELLOW}${BOLD}Notes:${RESET}" 
    echo -e "    - All of the usual git diff options are supported"
    echo -e "    - See the git-diff(1) man page for more information.\n"
}

show_hg_diff_help() {
    echo -e "${LTBLUE}${BOLD}Patchouli${RESET} - ${BOLD}hg diff${RESET}\n"
    echo -e "${YELLOW}${BOLD}Usage:${RESET}"
    echo -e "  ${LTBLUE}${BOLD}patchouli${RESET} diff [options]\n"

    echo -e "${YELLOW}${BOLD}Description:${RESET}"
    echo -e "Creates a Mercurial patch file from changes in the repository.\n"

    echo -e "${YELLOW}${BOLD}Mercurial-specific Options:${RESET}"
    echo -e "  ${ITALIC}-n, --num N${RESET}              # Number of revisions to include (default: 1)"
    echo -e "  ${ITALIC}-s, --since <rev>${RESET}        # Create diff since reference (revision number/tag)"
    echo -e "  ${ITALIC}-o, --output <file>${RESET}      # Output patch file (default: hg.patch)"
    echo -e "  ${ITALIC}-u, --unified${RESET}            # Output unified diff format"
    echo -e "  ${ITALIC}-c, --context${RESET}            # Output context diff format"
    echo -e "  ${ITALIC}-w, --ignore-all-space${RESET}   # Ignore all whitespace changes"
    echo -e "  ${ITALIC}-b, --ignore-space-change${RESET} # Ignore changes in whitespace amount"
    echo -e "  ${ITALIC}-B, --ignore-blank-lines${RESET} # Ignore changes inserting/deleting blank lines"
    echo -e "  ${ITALIC}-p, --show-function${RESET}      # Show which function each change is in"
    echo -e "  ${ITALIC}-g, --git${RESET}                # Use git extended diff format"
    echo -e "  ${ITALIC}-h, --help${RESET}               # Show this help message\n"

    echo -e "${YELLOW}${BOLD}Examples:${RESET}\n"
    echo -e "  ${LTBLUE}${BOLD}patchouli${RESET} diff file.txt      # Compare file.txt to last commit"
    echo -e "  ${LTBLUE}${BOLD}patchouli${RESET} diff -r 1234 -r 5678       # Compare revision 1234 to 5678\n"

    echo -e "${YELLOW}${BOLD}Notes:${RESET}" 
    echo -e "    - All of the usual hg diff options are supported"
    echo -e "    - See the hg-diff(1) man page for more information.\n"
}