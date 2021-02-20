.ONESHELL:
SHELL := /bin/bash

install_vim:
	if ! command -v vim &> /dev/null
	then
		sudo apt-get install git git-core vim vim-nox || true
	fi
	cp .vimrc ~/
	cp -r .vim ~/
	cp .bashrc ~/
	cp .gitconfig ~/
	# git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim || true
	# Bash conditions: https://tldp.org/LDP/Bash-Beginners-Guide/html/sect_07_01.html
	if [ ! -d /home/niekas/.vim/bundle/repos/github.com/Shougo/dein.vim ]
	then
		curl https://raw.githubusercontent.com/Shougo/dein.vim/master/bin/installer.sh > installer.sh
		sh ./installer.sh ~/.vim/bundle
		rm installer.sh || true
	fi
	vim +dein#install +qall
