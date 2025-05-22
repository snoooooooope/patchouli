#!/usr/bin/env bash

validate_hg_status() {
    if hg status | grep -q .; then
        warning_msg "Mercurial working directory is not clean. Consider committing or stashing your changes before patching."
        return "$ERROR_VCS"
    fi
}

hg_patch() {
    local patch_file=""
    local force=false

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -f|--force) force=true; shift ;;
            -h|--help) show_hg_patch_help; exit 0 ;;
            --) shift; break ;;
            *) patch_file="$1"; shift ;;
        esac
    done

    validate_file "$patch_file"

    if $force; then
        hg import --force "$patch_file"
    else
        hg import "$patch_file"
    fi
}