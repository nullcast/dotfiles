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
set -x LDFLAGS "-L/usr/local/opt/zlib/lib -L/usr/local/opt/bzip2/lib"
set -x CPPFLAGS "-I/usr/local/opt/zlib/include -I/usr/local/opt/bzip2/include"
set -x PKG_CONFIG_PATH "/usr/local/opt/zlib/lib/pkgconfig"
set -x LIBRARY_PATH "$LIBRARY_PATH:"(brew --prefix)"/lib"
set -x CPATH "$CPATH:"(brew --prefix)"/include"
