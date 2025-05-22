#!/usr/bin/env bash

run_diff() {
    if ! command -v diff >/dev/null 2>&1; then
        error_exit "Required 'diff' command not found. Please install diffutils." "$ERROR_MISSING_DEP"
    fi

    local original="" modified="" output_file="$DEFAULT_PATCH_FILE"
    local num_changes="" since_ref="" output_file_specified=false
    local diff_options=() files_after_options=()
    local vcs
    vcs=$(get_vcs)

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -o|--output)
                output_file="$2"
                output_file_specified=true
                [[ -z "$output_file" ]] && error_exit "Output file not specified." "$ERROR_INVALID_INPUT"
                validate_dir "$(dirname "$output_file")"
                shift 2
                ;;
            -n|--num)
                num_changes="$2"
                shift 2
                ;;
            -s|--since)
                since_ref="$2"
                shift 2
                ;;
            -h|--help|help)
                show_vcs_diff_help
                exit 0
                ;;
            --)
                shift
                files_after_options+=("$@")
                break
                ;;
            -*)
                diff_options+=("$1")
                shift
                ;;
            *)
                files_after_options+=("$1")
                shift
                while [[ $# -gt 0 && "$1" != -* ]]; do
                    files_after_options+=("$1")
                    shift
                done
                ;;
        esac
    done

    # Set default output file if not specified
    if [[ -z "$output_file" || "$output_file" == "$DEFAULT_PATCH_FILE" ]]; then
        case "$vcs" in
            git) output_file="$DEFAULT_GIT_PATCH_FILE" ;;
            hg) output_file="$DEFAULT_HG_PATCH_FILE" ;;
        esac
    fi

    if [[ -n "$num_changes" || -n "$since_ref" ]]; then
        case "$vcs" in
            git)
                run_vcs_diff "git" "$num_changes" "$since_ref" "$output_file" "${diff_options[@]}" "${files_after_options[@]}"
                ;;
            hg)
                run_vcs_diff "hg" "$num_changes" "$since_ref" "$output_file" "${diff_options[@]}" "${files_after_options[@]}"
                ;;
            *)
                warning_msg "VCS-specific options ignored (not in a Git/Mercurial repository). Showing standard diff help."
                show_diff_help
                exit 0
                ;;
        esac
        return
    fi

    if [[ "$vcs" != "none" && ${#files_after_options[@]} -eq 1 ]]; then
        # VCS mode with single file - diff against repository version
        case "$vcs" in
            git)
                echo -e "${BLUE}Git diff for '${files_after_options[0]}':${RESET}"
                if git diff HEAD -- "${files_after_options[0]}" | tee "$output_file"; then
                    if [[ -s "$output_file" ]]; then
                        echo -e "${GREEN}Success: Differences found and saved to $output_file${RESET}"
                    else
                        echo -e "${YELLOW}No differences found.${RESET}"
                    fi
                else
                    local exit_code=$?
                    [[ $exit_code -eq 1 ]] || error_exit "git command failed (exit $exit_code)." "$ERROR_VCS"
                fi
                ;;
            hg)
                echo -e "${BLUE}Mercurial diff for '${files_after_options[0]}':${RESET}"
                if hg diff "${files_after_options[0]}" | tee "$output_file"; then
                    if [[ -s "$output_file" ]]; then
                        echo -e "${GREEN}Success: Differences found and saved to $output_file${RESET}"
                    else
                        echo -e "${YELLOW}No differences found.${RESET}"
                    fi
                else
                    local exit_code=$?
                    [[ $exit_code -eq 1 ]] || error_exit "hg command failed (exit $exit_code)." "$ERROR_VCS"
                fi
                ;;
        esac
        return
    fi

    if [[ "$vcs" == "hg" && ${#files_after_options[@]} -eq 0 ]]; then
        echo -e "${BLUE}Mercurial diff for all uncommitted changes:${RESET}"
        if [[ "$output_file_specified" == "false" ]]; then
            hg diff
            exit 0
        else
            if hg diff | tee "$output_file"; then
                if [[ -s "$output_file" ]]; then
                    echo -e "${GREEN}Success: Differences found and saved to $output_file${RESET}"
                else
                    echo -e "${YELLOW}No differences found.${RESET}"
                fi
            else
                local exit_code=$?
                [[ $exit_code -eq 1 ]] || error_exit "hg command failed (exit $exit_code)." "$ERROR_VCS"
            fi
        fi
        return
    fi

    if [[ ${#files_after_options[@]} -eq 2 ]]; then
        original="${files_after_options[0]}"
        modified="${files_after_options[1]}"
        validate_file "$original"
        validate_file "$modified"

        echo -e "${BLUE}Creating patch from '$original' to '$modified'...${RESET}"
        if diff "${diff_options[@]}" -u "$original" "$modified" | tee "$output_file"; then
            if [[ -s "$output_file" ]]; then
                echo -e "${GREEN}Success: Differences found and saved to $output_file${RESET}"
            else
                echo -e "${YELLOW}Files are identical - no differences found.${RESET}"
            fi
        else
            local exit_code=$?
            case $exit_code in
                1)
                    if [[ -s "$output_file" ]]; then
                        echo -e "${GREEN}Success: Differences found and saved to $output_file${RESET}"
                    else
                        error_exit "Diff found but patch file is empty." "$ERROR_GENERAL"
                    fi
                    ;;
                2) error_exit "One or both input files do not exist." "$ERROR_INVALID_INPUT" ;;
                *) error_exit "command failed with exit code $exit_code." "$ERROR_GENERAL" ;;
            esac
        fi
    elif [[ ${#files_after_options[@]} -eq 0 ]]; then
        if command_exists gum; then
            log_info "No files specified. Using gum to select files interactively."

            local selected_original
            selected_original=$(gum file)
            if [[ -z "$selected_original" ]]; then
                error_exit "No original file selected." "$ERROR_INVALID_INPUT"
            fi

            local selected_modified
            selected_modified=$(gum file)
            if [[ -z "$selected_modified" ]]; then
                error_exit "No modified file selected." "$ERROR_INVALID_INPUT"
            fi

            original="$selected_original"
            modified="$selected_modified"

            validate_file "$original"
            validate_file "$modified"

            echo -e "${BLUE}Creating patch from '$original' to '$modified'...${RESET}"
            if diff "${diff_options[@]}" -u "$original" "$modified" | tee "$output_file"; then
                if [[ -s "$output_file" ]]; then
                    echo -e "${GREEN}Success: Differences found and saved to $output_file${RESET}"
                else
                    echo -e "${YELLOW}Files are identical - no differences found.${RESET}"
                fi
            else
                local exit_code=$?
                case $exit_code in
                    1)
                        if [[ -s "$output_file" ]]; then
                            echo -e "${GREEN}Success: Differences found and saved to $output_file${RESET}"
                        else
                            error_exit "Diff found but patch file is empty." "$ERROR_GENERAL"
                        fi
                        ;;
                    2) error_exit "One or both input files do not exist." "$ERROR_INVALID_INPUT" ;;
                    *) error_exit "command failed with exit code $exit_code." "$ERROR_GENERAL" ;;
                esac
            fi
        else
            error_exit "No files specified for diff operation." "$ERROR_INVALID_INPUT"
        fi
    else
        error_exit "Diff operation requires exactly two files (got ${#files_after_options[@]})." "$ERROR_INVALID_INPUT"
    fi
}

run_vcs_diff() {
    local vcs="$1" num_changes="$2" since_ref="$3" output_file="$4"
    shift 4
    local vcs_options=("$@")

    case "$vcs" in
        git)
            if ! git diff "${vcs_options[@]}" | tee "$output_file"; then
                error_exit "Git diff operation failed" "$ERROR_VCS"
            fi
            if [[ -s "$output_file" ]]; then
                echo -e "${GREEN}Success: Differences found and saved to $output_file${RESET}"
            else
                echo -e "${YELLOW}No differences found.${RESET}"
            fi
            ;;
        hg)
            if ! hg diff "${vcs_options[@]}" | tee "$output_file"; then
                error_exit "Mercurial diff operation failed" "$ERROR_VCS"
            fi
            if [[ -s "$output_file" ]]; then
                echo -e "${GREEN}Success: Differences found and saved to $output_file${RESET}"
            else
                echo -e "${YELLOW}No differences found.${RESET}"
            fi
            ;;
    esac
}

validate_file() {
    if [[ ! -f "$1" ]]; then
        error_exit "File '$1' does not exist" "$ERROR_INVALID_INPUT"
    fi
    if [[ ! -r "$1" ]]; then
        error_exit "Cannot read file '$1'" "$ERROR_PERMISSION"
    fi
}