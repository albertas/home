.ONESHELL:
SHELL := /bin/bash

install_nvim_with_vim_plug:
	# TODO: Use bash conditions not to ask for sudo if everything is installed or already in sudo:
	# 	https://tldp.org/LDP/Bash-Beginners-Guide/html/sect_07_01.html
	sudo apt-get install git git-core vim vim-nox neovim python3-neovim curl || true
	sudo pip install black flake8 || true
	mkdir -p ~/.config/nvim
	cp .vimrc ~/.config/nvim/init.vim
	cp -r .vim/* ~/.config/nvim
	mkdir -p ~/.vim
	cp .vimrc ~/.vimrc
	cp -r .vim/* ~/.vim
	cp .bashrc ~/
	cp .gitconfig ~/
	sh -c 'curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
