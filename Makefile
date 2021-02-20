.ONESHELL:
SHELL := /bin/bash

install_nvim_with_vim_plug:
	# Bash conditions: https://tldp.org/LDP/Bash-Beginners-Guide/html/sect_07_01.html
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
	sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
	vim +PlugInstall +qall

