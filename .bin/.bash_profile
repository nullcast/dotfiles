# Get the aliases and functions
if [ -r ~/.bashrc ]; then
  source ~/.bashrc
fi

# Set the prompt
export PS1='\n\[\e[1;31m\]\u \[\e[1;32m\]\W \[\e[1;33m\]\$ \[\e[0m\]'

# Set the language
export LANG="ja_JP.UTF-8"

# Set brew
if [ "$(which brew)" == "" ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Set vscode
if [ "$(which code)" == "" ]; then
  export PATH="/Applications/Visual\ Studio\ Code.app/Contents/Resources/app/bin:$PATH"
fi

# Set Typescript Compiler
if [ "$(which tsc)" == "" ]; then
  export PATH="$(npm bin -g):$PATH"
fi

# Set aws-completion
if [ "$(which aws_completer)" != "" ]; then
  complete -C aws_completer aws
fi

# Set bash-completion
if [ -r "/usr/local/etc/profile.d/bash_completion.sh" ]; then
  source /usr/local/etc/profile.d/bash_completion.sh
fi

# Set git-completion
if [ -r "/usr/local/etc/bash_completion.d/git-completion.sh" ]; then
  source /usr/local/etc/bash_completion.d/git-completion.sh
fi

# Set git-prompt
if [ -r "/usr/local/etc/bash_completion.d/git-prompt.sh" ]; then
  source /usr/local/etc/bash_completion.d/git-prompt.sh
fi

# OS X or Linux
case $(uname -a) in
  Darwin* )
    # Stop the bash silence deprecation warning
    export BASH_SILENCE_DEPRECATION_WARNING=1

  ;;
esac

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/mkurosawa/google-cloud-sdk/path.bash.inc' ]; then . '/Users/mkurosawa/google-cloud-sdk/path.bash.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/mkurosawa/google-cloud-sdk/completion.bash.inc' ]; then . '/Users/mkurosawa/google-cloud-sdk/completion.bash.inc'; fi

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/Users/mkurosawa/.local/share/mise/installs/python/miniforge3-24.3.0-0/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/Users/mkurosawa/.local/share/mise/installs/python/miniforge3-24.3.0-0/etc/profile.d/conda.sh" ]; then
        . "/Users/mkurosawa/.local/share/mise/installs/python/miniforge3-24.3.0-0/etc/profile.d/conda.sh"
    else
        export PATH="/Users/mkurosawa/.local/share/mise/installs/python/miniforge3-24.3.0-0/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

