#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../../lib/core/logging.sh" || exit 1
source "$(dirname "${BASH_SOURCE[0]}")/../../lib/core/error_handling.sh" || exit 1

run_diff() {
    if ! command -v diff >/dev/null 2>&1; then
        echo "Error: Required 'diff' command not found. Please install diffutils." >&2
        exit 1
    fi

    local original="" modified="" output_file="changes.patch"
    local num_changes="" since_ref=""
    local diff_options=() files_after_options=()
    local vcs
    vcs=$(get_vcs)

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -o|--output)
                output_file="$2"
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
                files_after_options=("$@")
                break
                ;;
            -*)
                diff_options+=("$1")
                shift
                ;;
            *)
                files_after_options+=("$1")
                shift
                ;;
        esac
    done

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

    if [[ ${#files_after_options[@]} -eq 2 ]]; then
        original="${files_after_options[0]}"
        modified="${files_after_options[1]}"
        validate_file "$original"
        validate_file "$modified"

        echo -e "${BLUE}Creating patch from '$original' to '$modified'...${RESET}"
        if ! diff "${diff_options[@]}" -u "$original" "$modified" > "$output_file" 2>&1; then
            local exit_code=$?
            [[ $exit_code -eq 1 && -s "$output_file" ]] || error_exit "Diff failed (exit $exit_code)." "$ERROR_GENERAL"
        fi
    elif [[ ${#files_after_options[@]} -eq 0 ]]; then
        error_exit "No files specified and no VCS detected." "$ERROR_INVALID_INPUT"
    else
        error_exit "diff requires exactly two files." "$ERROR_INVALID_INPUT"
    fi

    if [[ -s "$output_file" ]]; then
        echo -e "${GREEN}Patch created: $output_file${RESET}"
    else
        warning_msg "Empty patch file (no differences found)."
    fi
}

run_vcs_diff() {
    local vcs="$1" num_changes="$2" since_ref="$3" output_file="$4"
    shift 4
    local vcs_options=("$@")

    case "$vcs" in
        git)
            local git_cmd=()
            if [[ -n "$since_ref" ]]; then
                git_cmd=("git" "diff" "$since_ref" "--" "${vcs_options[@]}")
            elif [[ -n "$num_changes" ]]; then
                git_cmd=("git" "format-patch" "-${num_changes}" "--stdout" "${vcs_options[@]}")
            else
                git_cmd=("git" "diff" "HEAD" "${vcs_options[@]}")
            fi
            "${git_cmd[@]}" > "$output_file" 2>&1 || {
                local exit_code=$?
                [[ $exit_code -eq 1 ]] || error_exit "git command failed (exit $exit_code)."
            }
            ;;
        hg)
            local hg_cmd=()
            if [[ -n "$since_ref" ]]; then
                hg_cmd=("hg" "diff" "-r" "$since_ref" "--" "${vcs_options[@]}")
            elif [[ -n "$num_changes" ]]; then
                hg_cmd=("hg" "diff" "-r" "tip~${num_changes}:tip" "--" "${vcs_options[@]}")
            else
                hg_cmd=("hg" "diff" "${vcs_options[@]}")
            fi
            "${hg_cmd[@]}" > "$output_file" 2>&1 || {
                local exit_code=$?
                [[ $exit_code -eq 1 ]] || error_exit "hg command failed (exit $exit_code)."
            }
            ;;
    esac
}
