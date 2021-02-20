.ONESHELL:
SHELL := /bin/bash

install_vim:
	if ! command -v vim &> /dev/null
	then
		sudo apt-get install git git-core vim vim-nox || true
		sudo apt-get install neovim
		sudo apt-get install python3-neovim
	fi
	cp .vimrc ~/.config/nvim/init.vim
	cp -r .vim ~/.config/nvim
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
	nvim +dein#install +qall



