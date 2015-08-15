Add configs to Ubuntu
=====================
::

    sudo apt-get install git vim vim-gnome
    clone .vim/colors/wombat256.vim
    create dirs .vim/var/backup .vim/var/swap .vim/var/undo
    clone .vimrc
    clone .bashrc
    clone .gvimrc
    clone .gitconfig
    vim +PluginInstall +qall
