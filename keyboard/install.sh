# https://pqrs.org/osx/karabiner/document.html#configuration-file-path

test -e $HOME/.config/karabiner && rm -rf $HOME/.config/karabiner
ln -s  $DOTFILES/keyboard/karabiner $HOME/.config/karabiner

launchctl kickstart -k gui/`id -u`/org.pqrs.karabiner.karabiner_console_user_server
