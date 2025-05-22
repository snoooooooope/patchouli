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

    # If no diff options were provided and gum is available, let the user select interactively
    if [[ ${#diff_options[@]} -eq 0 ]] && command_exists gum; then
        log_info "No diff options specified. Choose options interactively:"
        local selected_options
        selected_options=$(gum choose --limit 0 "Unified Format" "Ignore Case" "Ignore All Space" "Ignore Space Change" "Ignore Blank Lines")
        diff_options=()
        for option in $selected_options; do
            case "$option" in
                "Unified Format") diff_options+=("-u") ;;
                "Ignore Case") diff_options+=("-i") ;;
                "Ignore All Space") diff_options+=("-w") ;;
                "Ignore Space Change") diff_options+=("-b") ;;
                "Ignore Blank Lines") diff_options+=("-B") ;;
            esac
        done
        if [[ ${#diff_options[@]} -gt 0 ]]; then
             log_info "Selected options: ${diff_options[*]}"
        fi
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
        if command_exists gum; then
            gum spin --spinner dot --title "Generating diff..." -- diff "${diff_options[@]}" -u "$original" "$modified" | tee "$output_file"
        else
            diff "${diff_options[@]}" -u "$original" "$modified" | tee "$output_file"
        fi

        if [[ -s "$output_file" ]]; then
            echo -e "${GREEN}Success: Differences found and saved to $output_file${RESET}"
        else
            echo -e "${YELLOW}Files are identical - no differences found.${RESET}"
        fi
    elif [[ ${#files_after_options[@]} -eq 0 ]]; then
        if command_exists gum; then
            log_info "No files specified. Using gum to select files interactively."

            local selected_original
            selected_original=$(gum file)
            if [[ -z "$selected_original" ]]; then
                error_exit "No original file selected." "$ERROR_INVALID_INPUT"
            fi
            log_info "Original file selected: $selected_original"

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
            if command_exists gum; then
                gum spin --spinner dot --title "Generating diff..." -- diff "${diff_options[@]}" -u "$original" "$modified" | tee "$output_file"
            else
                diff "${diff_options[@]}" -u "$original" "$modified" | tee "$output_file"
            fi

            if [[ -s "$output_file" ]]; then
                echo -e "${GREEN}Success: Differences found and saved to $output_file${RESET}"
            else
                echo -e "${YELLOW}Files are identical - no differences found.${RESET}"
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
    local vcs_options=()

    # Reconstruct vcs_options, excluding --num and --since
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -n|--num)
                shift 2
                ;;
            -s|--since)
                shift 2
                ;;
            *)
                vcs_options+=("$1")
                shift
                ;;
        esac
    done

    local diff_output
    case "$vcs" in
        git)
            if command_exists gum; then
                 diff_output=$(gum spin --spinner dot --title "Generating Git diff..." -- git diff "${vcs_options[@]}" 2>&1)
            else
                 diff_output=$(git diff "${vcs_options[@]}" 2>&1)
            fi
            if [[ -z "$diff_output" ]]; then
                echo -e "${YELLOW}No differences found.${RESET}"
            else
                echo "$diff_output" | tee "$output_file"
                if [[ -t 1 ]] && command_exists gum; then
                     echo "$diff_output" | gum pager
                fi
            fi

             if [[ -s "$output_file" ]]; then
                 echo -e "${GREEN}Success: Differences found and saved to $output_file${RESET}"
             fi
            ;;
        hg)
             if command_exists gum; then
                 diff_output=$(gum spin --spinner dot --title "Generating Mercurial diff..." -- hg diff "${vcs_options[@]}" 2>&1)
            else
                 diff_output=$(hg diff "${vcs_options[@]}" 2>&1)
            fi

            if [[ -z "$diff_output" ]]; then
                 echo -e "${YELLOW}No differences found.${RESET}"
             else
                 echo "$diff_output" | tee "$output_file"
                 if [[ -t 1 ]] && command_exists gum; then
                      echo "$diff_output" | gum pager
                 fi
             fi

             if [[ -s "$output_file" ]]; then
                 echo -e "${GREEN}Success: Differences found and saved to $output_file${RESET}"
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