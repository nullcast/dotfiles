#PYENV
set -x PYENV_ROOT $HOME/.pyenv
set -x PATH $PYENV_ROOT/bin $PATH
. (pyenv init - | psub)
set -x GLOBAL_PYTHON_VERSION 3.6.2
pyenv global $GLOBAL_PYTHON_VERSION

#VIRTUAL ENV
#. (pyenv virtualenv-init -)

#POWER LINE FOR SHELL
set TERM "screen-256color"
. $PYENV_ROOT/versions/$GLOBAL_PYTHON_VERSION/lib/python3.6/site-packages/powerline/bindings/fish/powerline-setup.fish
powerline-setup


