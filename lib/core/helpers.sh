#!/usr/bin/env bash

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

get_vcs() {
    if command_exists git && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        echo "git"
    elif command_exists hg && hg root >/dev/null 2>&1; then
        echo "hg"
    else
        echo "none"
    fi
}