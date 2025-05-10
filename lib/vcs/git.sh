#!/usr/bin/env bash

validate_git_status() {
    if ! git diff-index --quiet HEAD --; then
        warning_msg "Git working directory is not clean. Consider committing or stashing your changes before patching."
        return "$ERROR_VCS"
    fi
}

git_patch() {
    local patch_file=""
    local use_3way=false

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -3|--3way) use_3way=true; shift ;;
            -h|--help) show_git_patch_help; exit 0 ;;
            --) shift; break ;;
            *) patch_file="$1"; shift ;;
        esac
    done

    validate_file "$patch_file"

    if $use_3way; then
        git am --3way "$patch_file"
    else
        git apply "$patch_file"
    fi
}