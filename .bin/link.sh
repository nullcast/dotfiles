#!/bin/bash
set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Subdirectories under .config that ARE managed by this repo (version-controlled).
# Everything else under ~/.config (gcloud, firebase, ... credentials) must live
# in the REAL ~/.config — never inside the repo — so it is never symlinked in.
CONFIG_MANAGED=(brew fish jgit mise)

link() { # link <src> <dest>
    ln -fnsv "$1" "$2"
}

is_managed() {
    local name="$1" m
    for m in "${CONFIG_MANAGED[@]}"; do
        [[ "$name" == "$m" ]] && return 0
    done
    return 1
}

link_config() {
    local src_dir="$1" dest_dir="$HOME/.config"

    # Migrate the legacy layout where ~/.config was a single symlink into the
    # repo: drop the symlink (the repo data itself is untouched) and move any
    # unmanaged config (credentials etc.) out of the repo into a real ~/.config.
    if [[ -L "$dest_dir" ]]; then
        echo "Migrating legacy ~/.config symlink -> real directory"
        rm "$dest_dir"
        mkdir -p "$dest_dir"
        local entry name
        for entry in "$src_dir"/* "$src_dir"/.[!.]*; do
            [[ -e "$entry" ]] || continue
            name="$(basename "$entry")"
            is_managed "$name" && continue
            if [[ -e "$dest_dir/$name" ]]; then
                echo "  skip (already present): ~/.config/$name"
            else
                echo "  move out of repo: $name -> ~/.config/$name"
                mv "$entry" "$dest_dir/$name"
            fi
        done
    fi

    mkdir -p "$dest_dir"
    local name
    for name in "${CONFIG_MANAGED[@]}"; do
        [[ -e "$src_dir/$name" ]] && link "$src_dir/$name" "$dest_dir/$name"
    done
}

for dotfile in "${SCRIPT_DIR}"/.??* ; do
    case "$(basename "$dotfile")" in
        .git|.github|.DS_Store) continue ;;
        .config) link_config "$dotfile" ;;
        *) link "$dotfile" "$HOME/$(basename "$dotfile")" ;;
    esac
done
