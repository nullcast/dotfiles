# GENERAL
echo 'Init GENREAL'
set -x PATH /bin $PATH
set -x PATH /usr/local/bin $PATH
set -x PATH /usr/local/opt/openssl/bin $PATH

# POWERLINE SHELL
function fish_prompt
    powerline-shell --shell bare $status
end

echo 'Init GCP'
# The next line updates PATH for the Google Cloud SDK.
if test -f ~/google-cloud-sdk/path.fish.inc
    source ~/google-cloud-sdk/path.fish.inc
end

# The next line enables shell command completion for gcloud.
if test -f ~/google-cloud-sdk/completion.fish.inc
    source ~/google-cloud-sdk/completion.fish.inc
end

# GCloud
echo 'Init GCloud'
set -x CLOUDSDK_PYTHON (which python)
set -x CLOUDSDK_BQ_PYTHON (which python)
set -x CLOUDSDK_PYTHON_SITEPACKAGES 1

# LIB
echo 'Init LIB'
set -x LDFLAGS "-L/usr/local/opt/zlib/lib -L/usr/local/opt/bzip2/lib" "-L/opt/homebrew/opt/openal-soft/lib"
set -x CPPFLAGS "-I/usr/local/opt/zlib/include -I/usr/local/opt/bzip2/include" "-I/opt/homebrew/opt/openal-soft/include"
set -x PKG_CONFIG_PATH "/usr/local/opt/zlib/lib/pkgconfig" "/opt/homebrew/opt/openal-soft/lib/pkgconfig"
set -x LIBRARY_PATH "$LIBRARY_PATH:"(brew --prefix)"/lib"
set -x CPATH "$CPATH:"(brew --prefix)"/include"

# Pippetter
set -x PUPPETEER_SKIP_CHROMIUM_DOWNLOAD true
set -x PUPPETEER_EXECUTABLE_PATH (which chromium)

# Mysql client 
set -x PATH $PATH /opt/homebrew/opt/mysql-client/bin

# CMake
set -x CMAKE_PREFIX_PATH $(brew --prefix)

# Node
# set -x NODE_OPTIONS --openssl-legacy-provider

eval (/opt/homebrew/bin/mise activate fish)

# direnv
eval (direnv hook fish)

# 初期設定時に現在の Python バージョンを環境変数に保存
function save_python_version
    set -l python_version (mise current | grep 'python' | awk '{print $2}')
    set -gx PREV_PYTHON_VERSION $python_version
end
save_python_version

# update_mise_conda.fish を読み込む
source ~/.config/fish/.update_mise_conda.fish

function check_and_update_conda_version --on-event fish_prompt
    set -l current_python_version (mise current | grep 'python' | awk '{print $2}')

    # 現在の Python バージョンと以前のバージョンを比較
    if test "$current_python_version" != "$PREV_PYTHON_VERSION"
        update_mise_conda
        set -gx PREV_PYTHON_VERSION $current_python_version
    end
end

# pyenvのminiforgeのcondaの設定

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
if test -f /Users/mkurosawa/.local/share/mise/installs/python/miniforge3-24.3.0-0/bin/conda
    eval /Users/mkurosawa/.local/share/mise/installs/python/miniforge3-24.3.0-0/bin/conda "shell.fish" "hook" $argv | source
else
    if test -f "/Users/mkurosawa/.local/share/mise/installs/python/miniforge3-24.3.0-0/etc/fish/conf.d/conda.fish"
        . "/Users/mkurosawa/.local/share/mise/installs/python/miniforge3-24.3.0-0/etc/fish/conf.d/conda.fish"
    else
        set -x PATH "/Users/mkurosawa/.local/share/mise/installs/python/miniforge3-24.3.0-0/bin" $PATH
    end
end
# <<< conda initialize <<<

