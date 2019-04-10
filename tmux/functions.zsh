function tmka() {
  tmux kill-server 2>/dev/null
  test $? -gt 0 && >&2 tmux_color red "no tmux sessions"
}

function tml() {
  tmux list-sessions 2>/dev/null
  test $? -gt 0 && >&2 tmux_color red "no tmux sessions"
}

function tmn() {
  local dir=
  if [[ $# == 0 || $1 == '.' ]]; then
    dir=`realpath .`
  elif [ $1 =~ ^/ ]; then
    dir=$1
  else
    dir=$(
    tmux_find_project \
      $ZSH 1 $1 \
      $PROJECTS/$USER 1 $1 \
      $PROJECTS 2 $1 \
      $PROJECTS 3 $1 \
      ~ 1 $1 \
      ~ 2 $1 \
      /tmp 1 $1
    )
  fi
  if [ -z $dir ]; then
    tmux_start_session /tmp/$1
  else
    tmux_start_session $dir
  fi
}

function tmux_find_project() {
  local directory=$1
  local depth=$2
  local query=$3
  if [ $depth =~ [^0-9] ]; then
    depth=`echo $query | tr -cd / | wc -c`
  fi
  find \
    -L $directory \
    -mindepth $depth \
    -maxdepth $depth \
    -type d \
    -regex "\(.*\)\/$query$" \
    2> /dev/null | read -r project
  if [ ! -z $project ]; then
    echo $project | sed 's,^./,,'
    return
  fi
  if [ $# -gt 3 ]; then
    shift 3
    tmux_find_project $@
  else
    >&2 tmux_color red "no projects found"
    return 1
  fi
}

function tmux_start_session() {
  local dir="${1//$HOME/~}"
  vared -ep '%F{black}path:%f %B%F{blue}' dir
  test $? -gt 0 && return 1
  local realdir=`echo $dir | sed "s,~,$HOME,"`
  local safename=`echo $realdir | tr -d '.' | xargs basename`
  vared -ep '%F{black}name:%f %B%F{blue}' safename
  test $? -gt 0 && return 1
  if [[ ! -d $realdir ]]; then
    if [[ ! $realdir =~ ^/tmp/ ]]; then
      local answer=
      vared -ep "%F{black}make directory%f %B%F{blue}$dir%b%F{black}? [%f%F{white}Y%f%F{gray}n%f%F{black}]%f " answer
      if [[ ! -z $answer && ($answer = n || $answer = N) ]]; then
        >&2 tmux_color black "aborted" && return 1
      fi
    fi
    tmux_color black "creating $dir..."
    mkdir -p $realdir
  fi
  local existing_window=$(tmux list-window -t $safename -F '#S' 2>/dev/null)
  if [[ $? == 0 && $existing_window == $safename ]]; then
    local answer=
    vared -ep "%F{black}session%f %B%F{blue}$safename%b%F{black} already exists. attach? [%f%F{white}Y%f%F{gray}n%f%F{black}]%f " answer
    if [[ ! -z $answer && ($answer = n || $answer = N) ]]; then
      >&2 tmux_color black "aborted" && return 1
    else
      tmux_set_tab_title $safename
      tmux attach-session -t $safename -c $realdir
    fi
  else
    tmux_set_tab_title $safename
    tmux new-session -s $safename -c $realdir -n './'
  fi
}

function tmux_run() {
  tmux -S $(tmux_current_session) "$@"
}

function tmux_initialize_session_cwd() {
  if [ ! -z $TMUX ] && [ -z $TMUX_CWD ]; then
    export TMUX_CWD_REALPATH=$PWD
    export TMUX_CWD=$(sed -E "s,$HOME,\~," <<< $PWD)
    tmux_set_tab_title "$TMUX_CWD"
  fi
}

function tmux_relative_cwd() {
  if [ ! -z $TMUX ]; then
    local cwd=${1:-PWD}
    local relative_path="$(relpath $TMUX_CWD_REALPATH $cwd)"
    local local_path=''
    if [[ $relative_path == '.' ]]; then
      local_path=./
    elif [[ $relative_path == '..'* ]]; then
      local_path=$(sed -E "s,$HOME,\~," <<< $cwd)
    else
      local_path=./$relative_path
    fi
    tmux_run rename-window $local_path
  fi
}

function tmux_initialize_relative_cwd() {
  tmux_initialize_session_cwd
  tmux_relative_cwd "$@"
}

function tmux_set_tab_title() {
  local title_format{,ted}
  zstyle -s ':prezto:module:terminal:tab-title' format 'title_format' || title_format="%s"
  zformat -f title_formatted "$title_format" "s:$argv"
  printf "\e]1;%s\a" ${(V%)title_formatted}
}

function tmux_current_session() {
  if [ -z $TMUX ]; then
    >&2 tmux_color red "not in tmux session." && exit 1
  fi
  cut -d ',' -f1 <<< $TMUX
}

function tmux_color() {
  local value="$1"
  local content="${@:2}"
  local reset="\033[0m"
  case "$value" in
    black) value="\033[30m";;
    red) value="\033[31m";;
    yellow) value="\033[32m";;
    orange) value="\033[33m";;
    blue) value="\033[35m";;
    magenta) value="\033[35m";;
    cyan) value="\033[36m";;
    white) value="\033[37m";;
  esac
  print "$value$content$reset"
}
