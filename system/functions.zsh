# utility

if [[ -z $IGNORE_GLOB ]]; then
  IGNORE_GLOB=$(
    rg -v '(^\s*?\#|^\#|^$)' "$HOME/.gitignore" | \
      sort | \
      uniq | \
      tr '\n' '|' #| \
      # head --bytes -1
  )
  export IGNORE_GLOB;
fi

function relpath() {
  [[ $# -ge 1 ]] && [[ $# -le 2 ]] || return 1
  local target=${${2:-$1}:a} # replace `:a' by `:A` to resolve symlinks
  local current=${${${2:+$1}:-$PWD}:a} # replace `:a' by `:A` to resolve symlinks
  local appendix=${target#/}
  local relative=''
  while appendix=${target#$current/}
        [[ $current != '/' ]] && [[ $appendix = "$target" ]]; do
    if [[ $current = "$appendix" ]]; then
      relative=${relative:-.}
      print ${relative#/}
      return 0
    fi
    current=${current%/*}
    relative="$relative${relative:+/}.."
  done
  relative+=${relative:+${appendix:+/}}${appendix#/}
  print $relative
}

# display

function lsr() {
  exa \
    --all \
    --group-directories-first \
    --long \
    --modified \
    --sort Name \
    --time-style long-iso \
    --ignore-glob "$IGNORE_GLOB" \
    --git-ignore \
    "$@"
}

# navigation

function cd() {
  local arg="$@"
  local dir="$arg"
  local list=($(builtin dirs -p -l))

  if [[ -z $dir ]]; then
    return 1
  elif [[ $dir == '-' ]]; then
    dir=${list[-2]}
    for stored in $list; do
      if [[ $stored != $PWD ]] && [[ $stored =~ ^$PWD ]]; then
        dir=$stored
        break
      fi
    done
  elif [[ ! -d $dir ]]; then
    >&2 echo "no such file or directory: $dir" && return 1
  elif [[ $dir =~ '^\.' ]]; then
    dir=$(realpath $PWD/$dir)
  elif [[ ! $dir =~ '^/' ]]; then
    dir=$(realpath $dir)
  fi

  test $dir == $PWD && return 0

  tmux_initialize_session_cwd

  local pwd=$PWD
  if [[ ${list[(ie)$dir]} -gt ${#list} ]] && [[ $pwd =~ ^$dir ]]; then
    local dir_index=${list[(ie)$dir]}
    eval "popd -q -$dir_index" 2>/dev/null
  elif [[ $arg == '-' ]] && [[ ! $dir =~ ^$pwd ]]; then
    return 0
  else
    pushd -q $dir
  fi

  if [[ $PWD == $pwd ]]; then
    pushd -q $dir
  fi

  if [[ $PWD != $pwd ]]; then
    clear
    lsr .
    tmux_relative_cwd "$PWD"
  fi
}

function j() {
  cd .. || return 1;
}

function k() {
  cd - || return 1;
}

# search

function tree() {
  /usr/local/bin/tree \
    -I "$IGNORE_GLOB" \
    -C \
    -a \
    --dirsfirst \
    --noreport \
    "$@" | \
    more \
      --raw-control-chars \
      --quiet \
      --force
}

function ff() {
  local path=${1:-$PWD}
  local list=
  local files=
  list=$(ag '.' -lG '.' "$path" 2>/dev/null | fzf)
  if [[ -n $list ]]; then
    files=$(ls -1 "$list")
    if [[ -n $files ]] && [[ $(ls -1) =~ $files ]]; then
      if [[ $EDITOR == emacs ]]; then
        emacsclient --no-wait "$files";
      else
        $EDITOR "$files";
      fi
    fi
  fi
}

# processes

function killgrep() {
  ps aux | \
    rg "$@" | \
    rg -v " 0:00\.0\d rg $@"
}

function killport() {
  lsof -i :"$@" | \
    tr -s ' ' | \
    cut -d' ' -f2 | \
    tail --lines -1 | \
    xargs kill -9
}
