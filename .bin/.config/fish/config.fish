# POWERLINE GO
function fish_prompt
    # -error: 直前コマンドの終了コードで色などを変える
    # -shell bare: fish 向けにプロンプト文字列だけ出す
    powerline-go -error $status -shell bare
end

set -l brew_prefix (brew --prefix)

# The next line updates PATH for the Google Cloud SDK.
if test -f ~/google-cloud-sdk/path.fish.inc
    source ~/google-cloud-sdk/path.fish.inc
end

# The next line enables shell command completion for gcloud.
if test -f ~/google-cloud-sdk/completion.fish.inc
    source ~/google-cloud-sdk/completion.fish.inc
end

# GCloud: mise の Python を使う（Python が切り替わったら update_mise_conda から再設定）
function refresh_cloudsdk_python
    set -l py (command -s python)
    if set -q py[1]
        set -gx CLOUDSDK_PYTHON $py[1]
        set -gx CLOUDSDK_BQ_PYTHON $py[1]
    else
        set -e CLOUDSDK_PYTHON
        set -e CLOUDSDK_BQ_PYTHON
    end
end
refresh_cloudsdk_python
set -gx CLOUDSDK_PYTHON_SITEPACKAGES 1

# LIB (Apple Silicon の Homebrew 配下だけを見る)
set -gx LDFLAGS "-L$brew_prefix/opt/openal-soft/lib"
set -gx CPPFLAGS "-I$brew_prefix/opt/openal-soft/include"
set -gx PKG_CONFIG_PATH "$brew_prefix/opt/openal-soft/lib/pkgconfig"
# *PATH 変数は fish ではリスト。空要素（= カレントディレクトリ）を作らず、重複も足さない
contains -- $brew_prefix/lib $LIBRARY_PATH; or set -gx LIBRARY_PATH $LIBRARY_PATH $brew_prefix/lib
contains -- $brew_prefix/include $CPATH; or set -gx CPATH $CPATH $brew_prefix/include

# Puppeteer
set -gx PUPPETEER_SKIP_CHROMIUM_DOWNLOAD true
# chromium cask は Homebrew で disabled になったので、無ければ Google Chrome を使う
set -l chromium_bin (command -s chromium)
if set -q chromium_bin[1]
    set -gx PUPPETEER_EXECUTABLE_PATH $chromium_bin[1]
else if test -x "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
    set -gx PUPPETEER_EXECUTABLE_PATH "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
end

# Mysql client（-a: 末尾に追加、既にあれば何もしない）
fish_add_path -gaP $brew_prefix/opt/mysql-client/bin

# CMake
set -gx CMAKE_PREFIX_PATH $brew_prefix

# Node
# set -x NODE_OPTIONS --openssl-legacy-provider

# mise is activated in conf.d/mise.fish (loaded before config.fish)

# direnv
direnv hook fish | source

# 初期設定時に現在の Python バージョンを環境変数に保存
function save_python_version
    set -l python_version (mise current | grep 'python' | awk '{print $2}')
    set -gx PREV_PYTHON_VERSION $python_version
end
save_python_version

# update_mise_conda.fish を読み込む
source ~/.config/fish/.update_mise_conda.fish

function check_and_update_conda_version --on-variable PWD
    set -l current_python_version (mise current | grep 'python' | awk '{print $2}')

    # 現在の Python バージョンと以前のバージョンを比較
    if test "$current_python_version" != "$PREV_PYTHON_VERSION"
        update_mise_conda
        set -gx PREV_PYTHON_VERSION $current_python_version
    end
end
