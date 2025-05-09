#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../../lib/core/logging.sh" || exit 1

run_patch() {
    if ! command -v patch >/dev/null 2>&1; then
        echo "Error: Required 'patch' command not found. Please install patch." >&2
        exit 1
    fi

    local patch_file="" interactive=false
    local patch_options=() files_after_options=()
    local vcs=$(get_vcs)

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -i|--interactive)
                interactive=true
                shift
                ;;
            -3|--3way)
                if [[ "$vcs" != "git" ]]; then
                    warning_msg "3-way merge option ignored (not in a Git repository). Showing standard patch help."
                    show_patch_help
                    exit 0
                fi
                patch_options+=("$1")
                shift
                ;;
            -f|--force)
                if [[ "$vcs" != "hg" ]]; then
                    warning_msg "Force option ignored (not in a Mercurial repository). Showing standard patch help."
                    show_patch_help
                    exit 0
                fi
                patch_options+=("$1")
                shift
                ;;
            -h|--help|help)
                show_vcs_patch_help
                exit 0
                ;;
            --)
                shift
                patch_options=("$@")
                break
                ;;
            -*)
                patch_options+=("$1")
                shift
                ;;
            *)
                files_after_options+=("$1")
                shift
                ;;
        esac
    done

    [[ ${#files_after_options[@]} -gt 0 ]] || error_exit "Patch file not specified." $ERROR_INVALID_INPUT
    patch_file="${files_after_options[0]}"
    validate_file "$patch_file"
    [[ -s "$patch_file" ]] || { warning_msg "Empty patch file."; return; }

    if [[ "$vcs" != "none" ]]; then
        validate_vcs_status || confirm "Continue despite dirty working directory?" || exit 1
    fi

    # Apply patch based on VCS type
    case "$vcs" in
        git)
            if $interactive; then
                confirm "Apply Git patch from '$patch_file' interactively?" || exit 0
                git apply --reject "${patch_options[@]}" "$patch_file"
            else
                confirm "Apply Git patch from '$patch_file'?" || exit 0
                if ! git apply "${patch_options[@]}" "$patch_file" 2>&1; then
                    if ! git am "${patch_options[@]}" "$patch_file" 2>&1; then
                        error_exit "Git patch failed. Resolve conflicts manually or use '--reject'."
                    fi
                fi
            fi
            ;;
        hg)
            if $interactive; then
                warning_msg "Interactive mode not supported for Mercurial. Applying normally."
            fi
            confirm "Apply Mercurial patch from '$patch_file'?" || exit 0
            if ! hg import --no-commit "${patch_options[@]}" "$patch_file" 2>&1; then
                error_exit "Mercurial patch failed. Resolve conflicts manually or use '--force'."
            fi
            ;;
        *)
            if $interactive; then
                echo -e "${YELLOW}Interactive mode enabled. Follow prompts.${RESET}"
                patch -i "${patch_options[@]}" < "$patch_file"
            else
                confirm "Apply standard patch from '$patch_file'?" || exit 0
                if ! patch "${patch_options[@]}" < "$patch_file" 2>&1; then
                    error_exit "Patch failed. Resolve conflicts manually."
                fi
            fi
            ;;
    esac

    echo -e "${GREEN}Patch applied successfully.${RESET}"
}
