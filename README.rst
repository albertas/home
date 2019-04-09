Add configs to Ubuntu
=====================
::

    sudo apt-get install git git-core vim vim-gnome ctags   # sudo yum install git git-core vim vim-gnome ctags
    git clone https://github.com/strazdas/home
    cp -r home/.* ~/
    git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
    vim +PluginInstall +qall
    sudo pip3 install flake8 ipython ipdb
    ctags --languages='Python' -R .
