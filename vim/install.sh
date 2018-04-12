if [ ! -d ~/.vim/bundle/Vundle.vim ]; then
  git clone https://github.com/VundleVim/Vundle.vim ~/.vim/bundle/Vundle.vim
fi

if [ -f ~/.vim/colors/solarized.vim ]; then
  rm ~/.vim/colors/solarized.vim
fi

ln -s ~/.vim/bundle/vim-colors-solarized/colors/solarized.vim ~/.vim/colors/solarized.vim

vim +PluginInstall +qall
