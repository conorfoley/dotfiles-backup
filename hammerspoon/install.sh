if [ ! -d ~/.hammerspoon ]; then
  git clone https://github.com/ashfinal/awesome-hammerspoon ~/.hammerspoon
fi

if [ ! -d ~/.config/hammerspoon/private ]; then
  mkdir -p ~/.config/hammerspoon/private
fi

if [ ! -e ~/.config/hammerspoon/private/config.lua ]; then
  ln -s ~/.dotfiles/hammerspoon/config.lua ~/.config/hammerspoon/private/config.lua
fi
