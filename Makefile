install_vim:
	apt-get install git git-core vim vim-nox || true
	cp .vimrc ~/
	cp -r .vim ~/
	cp .bashrc ~/
	cp .gitconfig ~/
	git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim || true
	vim +PluginInstall +qall
