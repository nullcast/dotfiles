#!/bin/bash
set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Subdirectories under .config that ARE managed by this repo (version-controlled).
# Everything else under ~/.config (gcloud, firebase, ... credentials) must live
# in the REAL ~/.config — never inside the repo — so it is never symlinked in.
CONFIG_MANAGED=(brew fish jgit mise)

link() { # link <src> <dest>
    local src="$1" dest="$2" backup
    if [[ -d "$dest" && ! -L "$dest" ]]; then
        backup="${dest}.dotfiles-backup"
        if [[ -e "$backup" || -L "$backup" ]]; then
            echo "Refusing to replace directory; backup already exists: $backup" >&2
            return 1
        fi
        echo "Back up existing directory: $dest -> $backup"
        mv "$dest" "$backup"
    fi
    ln -fnsv "$src" "$dest"
}

is_managed() {
    local name="$1" m
    for m in "${CONFIG_MANAGED[@]}"; do
        [[ "$name" == "$m" ]] && return 0
    done
    return 1
}

rollback_config_migration() { # rollback_config_migration <src> <stage> <names...>
    local src_dir="$1" stage_dir="$2" name failed=0
    shift 2

    for name in "$@"; do
        if [[ -e "$stage_dir/$name" || -L "$stage_dir/$name" ]]; then
            if ! mv "$stage_dir/$name" "$src_dir/$name"; then
                echo "WARNING: failed to restore config entry: $stage_dir/$name" >&2
                failed=1
            fi
        fi
    done
    if ! rmdir "$stage_dir" 2>/dev/null; then
        echo "WARNING: config migration staging directory remains: $stage_dir" >&2
        failed=1
    fi
    return "$failed"
}

link_config() {
    local src_dir="$1" dest_dir="$HOME/.config"

    # Migrate the legacy layout where ~/.config was a single symlink into the
    # repo: drop the symlink (the repo data itself is untouched) and move any
    # unmanaged config (credentials etc.) out of the repo into a real ~/.config.
    if [[ -L "$dest_dir" ]]; then
        echo "Migrating legacy ~/.config symlink -> real directory"
        local entry name stage_dir legacy_link
        local -a moved=()

        if ! stage_dir="$(mktemp -d "$HOME/.config.dotfiles-migration.XXXXXX")"; then
            echo "WARNING: could not create config migration staging directory; legacy symlink kept" >&2
            return 1
        fi

        for entry in "$src_dir"/* "$src_dir"/.[!.]*; do
            [[ -e "$entry" || -L "$entry" ]] || continue
            name="$(basename "$entry")"
            is_managed "$name" && continue
            echo "  stage outside repo: $name"
            if ! mv "$entry" "$stage_dir/$name"; then
                echo "WARNING: failed to stage $name; legacy ~/.config symlink kept" >&2
                rollback_config_migration "$src_dir" "$stage_dir" "${moved[@]}" || true
                return 1
            fi
            moved+=("$name")
        done

        # Keep the legacy symlink until every unmanaged entry is safely staged.
        # Renaming it also lets us restore the original layout if finalization fails.
        legacy_link="${stage_dir}.legacy-link"
        if ! mv "$dest_dir" "$legacy_link"; then
            echo "WARNING: failed to preserve legacy ~/.config symlink" >&2
            rollback_config_migration "$src_dir" "$stage_dir" "${moved[@]}" || true
            return 1
        fi
        if ! mv "$stage_dir" "$dest_dir"; then
            echo "WARNING: failed to install migrated ~/.config directory; restoring legacy symlink" >&2
            if ! mv "$legacy_link" "$dest_dir"; then
                echo "WARNING: could not restore legacy symlink from $legacy_link" >&2
            fi
            rollback_config_migration "$src_dir" "$stage_dir" "${moved[@]}" || true
            return 1
        fi
        if ! rm "$legacy_link"; then
            echo "WARNING: migration succeeded, but legacy symlink remains at $legacy_link" >&2
            return 1
        fi
    fi

    mkdir -p "$dest_dir"
    local name
    for name in "${CONFIG_MANAGED[@]}"; do
        if [[ -e "$src_dir/$name" ]]; then
            link "$src_dir/$name" "$dest_dir/$name"
        fi
    done
}

for dotfile in "${SCRIPT_DIR}"/.??* ; do
    case "$(basename "$dotfile")" in
        .git|.github|.DS_Store) continue ;;
        .config) link_config "$dotfile" ;;
        *) link "$dotfile" "$HOME/$(basename "$dotfile")" ;;
    esac
done
