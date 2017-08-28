#!/bin/sh
# ${0} の dirname を取得
cwd=`dirname "${0}"`

#CD
cd $cwd

#NEO BUNDLE
git clone git://github.com/Shougo/neobundle.vim ~/.vim/bundle/neobundle.vim

#VIMRC
\cp -f ./.vimrc ~/.vimrc

#FISH
sudo wget http://download.opensuse.org/repositories/shells:fish:release:2/CentOS_7/shells:fish:release:2.repo -P /etc/yum.repos.d/
sudo yum install -y fish

#GCC
sudo yum install -y gcc

#CREATE TMP DIR
mkdir ./tmp

#GIT
wget https://www.kernel.org/pub/software/scm/git/git-2.9.5.tar.gz -P ./tmp
cd tmp
sudo yum -y install curl-devel expat-devel gettext-devel openssl-devel zlib-devel
sudo tar xzvf git-2.7.2.tar.gz
cd git-2.9.5
sudo make prefix=/usr/local all
sudo make prefix=/usr/local install
cd $cwd

#PYENV
sudo yum -y install readline-devel bzip2-devel sqlite-devel openssl-devel
git clone https://github.com/yyuu/pyenv.git ~/.pyenv
set -x PYENV_ROOT $HOME/.pyenv
set -x PATH $PYENV_ROOT/bin $PATH
. (pyenv init - | psub)

#PYTHON INSTALL
GROBAL_PYTHON_VERSION=3.6.2
pyenv install $GROBAL_PYTHON_VERSION

#SET PYTHON VERSION
pyenv global $GROBAL_PYTHON_VERSION

#VERTUAL ENV
git clone https://github.com/yyuu/pyenv-virtualenv.git ~/.pyenv/plugins/pyenv-virtualenv

#POWERLINE
pip install git+git://github.com/Lokaltog/powerline
sudo wget https://github.com/powerline/powerline/raw/develop/font/PowerlineSymbols.otf -P /usr/share/fonts/
sudo fc-cache -vf /usr/share/fonts/
sudo wget https://github.com/powerline/powerline/raw/develop/font/10-powerline-symbols.conf -P /etc/fonts/conf.d/

#CONFIG FISH
\cp -f ./.config/fish/config.fish ~/.config/fish/config.fish
