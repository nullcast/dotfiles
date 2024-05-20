# GENERAL
echo 'Init GENREAL'
set -x PATH /bin $PATH
set -x PATH /usr/local/bin $PATH
set -x PATH /usr/local/opt/openssl/bin $PATH

# POWERLINE SHELL
function fish_prompt
    powerline-shell --shell bare $status
end

# AnyEnv
echo 'Init Anyenv'
eval (anyenv init - fish | source)

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
set -x CLOUDSDK_PYTHON ~/.anyenv/envs/pyenv/shims/python
set -x CLOUDSDK_BQ_PYTHON ~/.anyenv/envs/pyenv/shims/python
set -x CLOUDSDK_PYTHON_SITEPACKAGES 1

# LIB
echo 'Init LIB'
set -x LDFLAGS "-L/usr/local/opt/zlib/lib -L/usr/local/opt/bzip2/lib" "-L/opt/homebrew/opt/openal-soft/lib"
set -x CPPFLAGS "-I/usr/local/opt/zlib/include -I/usr/local/opt/bzip2/include" "-I/opt/homebrew/opt/openal-soft/include"
set -x PKG_CONFIG_PATH "/usr/local/opt/zlib/lib/pkgconfig" "/opt/homebrew/opt/openal-soft/lib/pkgconfig"
set -x LIBRARY_PATH "$LIBRARY_PATH:"(brew --prefix)"/lib"
set -x CPATH "$CPATH:"(brew --prefix)"/include"

# Java
echo 'Init Java'
jenv add (/usr/libexec/java_home -v "18")
jenv add (/usr/libexec/java_home -v "1.8")
set -x JAVA_HOME (/usr/libexec/java_home -v "1.8")
set -x PATH $PATH $JAVA_HOME/bin

# Pippetter
set -x PUPPETEER_SKIP_CHROMIUM_DOWNLOAD true
set -x PUPPETEER_EXECUTABLE_PATH (which chromium)

# Mysql client 
set -x PATH $PATH /opt/homebrew/opt/mysql-client/bin

# CMake
set -x CMAKE_PREFIX_PATH $(brew --prefix)

# Node
# set -x NODE_OPTIONS --openssl-legacy-provider

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
eval /Users/mkurosawa/.anyenv/envs/pyenv/versions/miniforge3-22.9.0-3/bin/conda "shell.fish" "hook" $argv | source
# <<< conda initialize <<<

eval (/opt/homebrew/bin/mise activate fish)
