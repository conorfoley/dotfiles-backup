tmka() {
  tmux kill-server 2>/dev/null
  test $? -gt 0 && >&2 echo "no tmux sessions"
}

tml() {
  tmux list-sessions 2>/dev/null
  test $? -gt 0 && >&2 echo "no tmux sessions"
}

tmn() {
  local dir=

  if [[ $# == 0 || $1 == '.' ]]; then
    dir=`realpath .`
  elif [ $1 =~ ^/ ]; then
    dir=$1
  else
    dir=$(
    find_project \
      $ZSH 1 $1 \
      $PROJECTS/$USER 1 $1 \
      $PROJECTS 2 $1 \
      $PROJECTS 4 $1 \
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

tmux_initialize_session_cwd() {
  if [ ! -z $TMUX ] && [ -z $TMUX_CWD ]; then
    export TMUX_CWD_REALPATH=$PWD
    export TMUX_CWD=$(sed -E "s,$HOME,\~," <<< $PWD)
    set-tab-title "$TMUX_CWD"
  fi
}

tmux_relative_cwd() {
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
    set-window-title $local_path
  fi
}

tmux_initialize_relative_cwd() {
  tmux_initialize_session_cwd
  tmux_relative_cwd "$@"
}

tmux_start_session() {
  local dir=`echo $1 | sed "s,$HOME,~,"`
  vared -p "path: " dir
  test $? -gt 0 && return 1
  local realdir=`echo $dir | sed "s,~,$HOME,"`
  local safename=`echo $realdir | tr -d '.' | xargs basename`
  vared -p "name: " safename
  test $? -gt 0 && return 1

  if [[ ! -d $realdir ]]; then
    if [[ ! $realdir =~ ^/tmp/ ]]; then
      local answer=
      vared -p "make directory $realdir? [Yn] " answer
      if [[ ! -z $answer && ($answer = n || $answer = N) ]]; then
        >&2 echo "aborted."
        return 1
      fi
    fi

    echo "creating $dir..."
    mkdir -p $realdir
  fi

  local existing_window=$(tmux list-window -t $safename -F '#S' 2>/dev/null)

  if [[ $? == 0 && $existing_window == $safename ]]; then
    local answer=
    vared -p "session $safename already exists. attach? [Yn] " answer
    if [[ ! -z $answer && ($answer = n || $answer = N) ]]; then
      >&2 echo "aborted."
      return 1
    else
      set-tab-title $safename
      tmux attach-session -t $safename -c $realdir
    fi
  else
    set-tab-title $safename
    tmux new-session -s $safename -c $realdir -n './'
  fi
}

find_project() {
  local directory=$1
  local depth=$2
  local query=$3

  if [ $depth =~ [^0-9] ]; then
    depth=`echo $query | tr -cd / | wc -c`
  fi

  find \
    -L $directory \
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
    find_project $@
  else
    >&2 echo "no projects found"
    return 1
  fi
}

function set-tab-title() {
  local title_format{,ted}
  zstyle -s ':prezto:module:terminal:tab-title' format 'title_format' || title_format="%s"
  zformat -f title_formatted "$title_format" "s:$argv"

  printf "\e]1;%s\a" ${(V%)title_formatted}
}

function set-window-title() {
  local title_format{,ted}
  zstyle -s ':prezto:module:terminal:window-title' format 'title_format' || title_format="%s"
  zformat -f title_formatted "$title_format" "s:$argv"

  if [[ "$TERM" == screen* ]]; then
    title_format="\ek%s\e\\"
  else
    title_format="\e]2;%s\a"
  fi

  printf "$title_format" "${(V%)title_formatted}"
}
