# configure history with 'hstr'
# https://github.com/dvorka/hstr
export HISTFILE=$HOME/.zsh_history  # ensure history file visibility
export HH_CONFIG=hicolor            # get more colors
bindkey -s "\C-r" "\eqhh\n"         # bind hh to Ctrl-r (for Vi mode check doc)

if [ -f ~/.fzf.zsh ]; then
  source ~/.fzf.zsh
fi

function test_ff {
  # print "\033[J"
  /usr/bin/clear

  /bin/rm /tmp/fzf_buffer 2>/dev/null

  if [[ $1 =~ "^--" ]]; then
    local path=$PWD
    local opts=($path ${@:2})
  else
    local path=${1:-$PWD}
    local opts=()
  fi
  local dirname=$(/usr/local/bin/dirname "$path")
  local escaped=${path// /\\ }

  local enter_cmd="open_file $escaped/{}"
  local preview_cmd="preview_file $escaped/{}"
  local backwards_cmd="echo $(/usr/local/bin/dirname $path) > /tmp/fzf_buffer"
  local cancel_cmd="/bin/rm -rf /tmp/fzf_buffer 2>/dev/null"

  # emacs modifier key aliases
  local S=shift
  local C=ctrl
  local M=alt

  local keys="
$M-f : top
$M-v : page-up
$C-v : page-down
$C-u : preview-page-up
$C-d : preview-page-down
$C-y : preview-up
$C-e : preview-down
$C-l : execute($enter_cmd)+abort
$C-h : execute($backwards_cmd)+abort
$C-c : execute($cancel_cmd)+abort
$C-d : execute($cancel_cmd)+abort
esc : execute($cancel_cmd)+abort
enter : execute($enter_cmd)+abort
"

  local files=$(/usr/local/bin/exa -1 -a --group-directories-first --modified --sort Name --time-style long-iso --ignore-glob "$IGNORE_GLOB" --git-ignore --color=always "$path")
  local count=$(/usr/bin/wc -l <<< $files | /usr/local/bin/tr -d ' ')
  local prompt="${path/$HOME/~}"

  local opts=(
    --ansi
    --no-clear
    --inline-info
    --layout=reverse
    --prompt="$path/"
  )

  if [ $count -gt 0 ]; then
    local dirs=$(/usr/bin/find $path -maxdepth 1 -type d | /usr/local/bin/head -n -1 | /usr/bin/wc -l | /usr/local/bin/tr -d ' ')
    if [ $dirs -ne $count ]; then
      local lines=$(((((10000 / $LINES) * ($count) / 100))))
      local height=$((100 - $lines))
      if [ $height -lt 0 ]; then; height=0;
      elif [ $height -gt 99 ]; then; height=99;
      fi
      opts+=(
        --preview=$preview_cmd
        --preview-window="down:$height%"
      )
    fi
  fi

  opts+=(
    --bind=${${${keys:1:-1}//$'\n'/,}// : /:}
  )

  # /usr/local/bin/echo $preview_window
  # /usr/local/bin/echo $opts
  # return

  /usr/local/bin/fzf $opts <<< $files

  if [ -e /tmp/fzf_buffer ]; then
    local dir=$(/usr/local/bin/cat /tmp/fzf_buffer)

    /bin/rm /tmp/fzf_buffer
    builtin cd $dir
    test_ff $dir
  fi
}
