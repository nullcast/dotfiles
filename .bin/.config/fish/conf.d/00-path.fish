# mise activateより先に必要なbootstrap／system PATHだけを設定する。
# fish_add_pathは既存要素を重複させず、後続のmise tool PATHはこの前へ入る。
fish_add_path -g \
    /opt/homebrew/bin \
    ~/.local/bin \
    ~/.local/share/mise/bin \
    /usr/local/opt/openssl/bin \
    /usr/local/bin \
    /bin
