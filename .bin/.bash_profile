# Get the aliases and functions
if [ -r ~/.bashrc ]; then
  # shellcheck source=/dev/null
  source ~/.bashrc
fi

# Set the prompt
export PS1='\n\[\e[1;31m\]\u \[\e[1;32m\]\W \[\e[1;33m\]\$ \[\e[0m\]'

# Set the language
export LANG="ja_JP.UTF-8"

# Set brew
if ! command -v brew >/dev/null 2>&1; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi
BREW_PREFIX="$(brew --prefix 2>/dev/null)"

# Set vscode
if ! command -v code >/dev/null 2>&1; then
  export PATH="/Applications/Visual Studio Code.app/Contents/Resources/app/bin:$PATH"
fi

# Set aws-completion
if command -v aws_completer >/dev/null 2>&1; then
  complete -C aws_completer aws
fi

# Set bash-completion
if [ -r "${BREW_PREFIX}/etc/profile.d/bash_completion.sh" ]; then
  source "${BREW_PREFIX}/etc/profile.d/bash_completion.sh"
fi

# Set git-completion
if [ -r "${BREW_PREFIX}/etc/bash_completion.d/git-completion.bash" ]; then
  source "${BREW_PREFIX}/etc/bash_completion.d/git-completion.bash"
fi

# Set git-prompt
if [ -r "${BREW_PREFIX}/etc/bash_completion.d/git-prompt.sh" ]; then
  source "${BREW_PREFIX}/etc/bash_completion.d/git-prompt.sh"
fi

# OS X or Linux
case $(uname -a) in
  Darwin* )
    # Stop the bash silence deprecation warning
    export BASH_SILENCE_DEPRECATION_WARNING=1

  ;;
esac

# The next line updates PATH for the Google Cloud SDK.
# shellcheck source=/dev/null
if [ -f "$HOME/google-cloud-sdk/path.bash.inc" ]; then . "$HOME/google-cloud-sdk/path.bash.inc"; fi

# The next line enables shell command completion for gcloud.
# shellcheck source=/dev/null
if [ -f "$HOME/google-cloud-sdk/completion.bash.inc" ]; then . "$HOME/google-cloud-sdk/completion.bash.inc"; fi

# conda: mise で入れた miniforge があれば使う（バージョンやユーザー名は決め打ちしない）
_conda=""
for _c in "$HOME"/.local/share/mise/installs/python/miniforge3-*/bin/conda; do
  [ -x "$_c" ] && _conda="$_c"
done
if [ -n "$_conda" ]; then
  __conda_setup="$("$_conda" shell.bash hook 2>/dev/null)" && eval "$__conda_setup"
  unset __conda_setup
fi
unset _c _conda

