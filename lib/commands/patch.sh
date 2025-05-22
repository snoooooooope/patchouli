#!/usr/bin/env bash

run_patch() {
    if ! command -v patch >/dev/null 2>&1; then
        error_exit "Required 'patch' command not found. Please install patch." "$ERROR_MISSING_DEP"
    fi

    local patch_file="$DEFAULT_PATCH_FILE" interactive=false
    local patch_options=() files_after_options=()
    local vcs
    vcs=$(get_vcs)

    # Set default patch file if not specified
    if [[ ${#files_after_options[@]} -eq 0 && -f "$DEFAULT_PATCH_FILE" ]]; then
        case "$vcs" in
            git) 
                if [[ -f "$DEFAULT_GIT_PATCH_FILE" ]]; then
                    patch_file="$DEFAULT_GIT_PATCH_FILE"
                fi
                ;;
            hg)
                if [[ -f "$DEFAULT_HG_PATCH_FILE" ]]; then
                    patch_file="$DEFAULT_HG_PATCH_FILE"
                fi
                ;;
        esac
    fi

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

    if [[ ${#files_after_options[@]} -eq 0 ]]; then
        if command_exists gum; then
            log_info "No patch file specified. Using gum to select the patch file interactively."
            local selected_patch_file
            selected_patch_file=$(gum file)
            if [[ -z "$selected_patch_file" ]]; then
                error_exit "No patch file selected." "$ERROR_INVALID_INPUT"
            fi
            patch_file="$selected_patch_file"
        else
            error_exit "Patch file not specified." "$ERROR_INVALID_INPUT"
        fi
    else
        patch_file="${files_after_options[0]}"
    fi

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
                git apply --reject "${patch_options[@]}" "$patch_file" || {
                    error_exit "Git patch failed. Resolve conflicts manually or use '--reject'." "$ERROR_VCS"
                }
            else
                confirm "Apply Git patch from '$patch_file'?" || exit 0
                if ! git apply "${patch_options[@]}" "$patch_file" 2>&1; then
                    if ! git am "${patch_options[@]}" "$patch_file" 2>&1; then
                        error_exit "Git patch failed. Resolve conflicts manually or use '--reject'." "$ERROR_VCS"
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
                if [[ " ${patch_options[*]} " =~ " --force " || " ${patch_options[*]} " =~ " -f " ]]; then
                    hg import --no-commit --force "$patch_file" || error_exit "Mercurial patch failed even with --force." "$ERROR_VCS"
                else
                    error_exit "Mercurial patch failed. Resolve conflicts manually or use '--force'." "$ERROR_VCS"
                fi
            fi
            ;;
        *)
            if $interactive; then
                echo -e "${YELLOW}Interactive mode enabled. Follow prompts.${RESET}"
                patch -i "${patch_options[@]}" < "$patch_file" || {
                    error_exit "Patch failed. Resolve conflicts manually." "$ERROR_GENERAL"
                }
            else
                confirm "Apply standard patch from '$patch_file'?" || exit 0
                if ! patch "${patch_options[@]}" < "$patch_file" 2>&1; then
                    error_exit "Patch failed. Resolve conflicts manually." "$ERROR_GENERAL"
                fi
            fi
            ;;
    esac

    echo -e "${GREEN}Patch applied successfully.${RESET}"
}