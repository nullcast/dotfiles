# === 最低限のPATHだけ先に通す（他はまだ触らない） ===
if test -d /opt/homebrew/bin
    fish_add_path -g /opt/homebrew/bin
end
if test -d ~/.local/bin
    fish_add_path -g ~/.local/bin
end
if test -d ~/.local/share/mise/bin
    fish_add_path -g ~/.local/share/mise/bin
end
