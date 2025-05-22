#!/usr/bin/env bash

get_vcs() {
    if command_exists git && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        echo "git"
    elif command_exists hg && hg root >/dev/null 2>&1; then
        echo "hg"
    else
        echo "none"
    fi
}

require_vcs() {
    local vcs
    vcs=$(get_vcs)
    [[ "$vcs" != "none" ]] || error_exit "No supported VCS (Git/Mercurial) detected in this directory." "$ERROR_VCS"
    echo "$vcs"
} 