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
    echo -e "  # Basic file comparison"
    echo -e "  ${LTBLUE}${BOLD}patchouli${RESET} diff file1.txt file2.txt\n"
    echo -e "  # Unified diff format with output file"
    echo -e "  ${LTBLUE}${BOLD}patchouli${RESET} diff -u old.c new.c -o changes.patch\n"
    echo -e "  # Recursive directory comparison"
    echo -e "  ${LTBLUE}${BOLD}patchouli${RESET} diff -r dir1/ dir2/\n"
    echo -e "  # Ignore whitespace changes"
    echo -e "  ${LTBLUE}${BOLD}patchouli${RESET} diff -w config.old config.new\n"
    echo -e "  # Case-insensitive comparison"
    echo -e "  ${LTBLUE}${BOLD}patchouli${RESET} diff -i README.md readme.md\n"

    echo -e "${YELLOW}${BOLD}Notes:${RESET}"
    echo -e "  - All of the usual diff options are supported, but are far too many to list here."
    echo -e "    - See the diff(1) man page for more information."
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
    echo -e "  ${ITALIC}-w, --ignore-all-space${RESET}   # Ignore all whitespace changes"
    echo -e "  ${ITALIC}-b, --ignore-space-change${RESET} # Ignore changes in whitespace amount"
    echo -e "  ${ITALIC}-B, --ignore-blank-lines${RESET} # Ignore changes inserting/deleting blank lines"
    echo -e "  ${ITALIC}-p, --patch${RESET}              # Generate patch (default)"
    echo -e "  ${ITALIC}-U<n>, --unified=<n>${RESET}     # Generate diffs with <n> lines of context"
    echo -e "  ${ITALIC}-h, --help${RESET}               # Show this help message\n"

    echo -e "${YELLOW}${BOLD}Examples:${RESET}\n"
    echo -e "  # Compare text.txt to last commit"
    echo -e "  ${LTBLUE}${BOLD}patchouli${RESET} diff text.txt\n"
    echo -e "  # Compare two specific commits"
    echo -e "  ${LTBLUE}${BOLD}patchouli${RESET} diff abc123 def456\n"
    echo -e "  # Show changes in last 3 commits"
    echo -e "  ${LTBLUE}${BOLD}patchouli${RESET} diff -n 3\n"
    echo -e "  # Unified diff with 5 lines of context"
    echo -e "  ${LTBLUE}${BOLD}patchouli${RESET} diff -U5\n"
    echo -e "  # Compare branch to main"
    echo -e "  ${LTBLUE}${BOLD}patchouli${RESET} diff main..feature-branch\n"
    echo -e "  # Ignore whitespace changes"
    echo -e "  ${LTBLUE}${BOLD}patchouli${RESET} diff -w\n"
    echo -e "  # Output to specific patch file"
    echo -e "  ${LTBLUE}${BOLD}patchouli${RESET} diff -o changes.patch\n"
    echo -e "  # Show changes since tag v1.0"
    echo -e "  ${LTBLUE}${BOLD}patchouli${RESET} diff -s v1.0\n"
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
    echo -e "  # Compare file.txt to last commit"
    echo -e "  ${LTBLUE}${BOLD}patchouli${RESET} diff file.txt\n"
    echo -e "  # Compare two specific revisions"
    echo -e "  ${LTBLUE}${BOLD}patchouli${RESET} diff -r 1234 -r 5678\n"
    echo -e "  # Unified diff format with output file"
    echo -e "  ${LTBLUE}${BOLD}patchouli${RESET} diff -u -o changes.patch\n"
    echo -e "  # Ignore whitespace changes"
    echo -e "  ${LTBLUE}${BOLD}patchouli${RESET} diff -w\n"
    echo -e "  # Show function context for changes"
    echo -e "  ${LTBLUE}${BOLD}patchouli${RESET} diff -p\n"
    echo -e "  # Compare against a specific branch"
    echo -e "  ${LTBLUE}${BOLD}patchouli${RESET} diff -r default -r feature-branch\n"
    echo -e "  # Use Git extended diff format"
    echo -e "  ${LTBLUE}${BOLD}patchouli${RESET} diff -g\n"
}
