# utility

function get_ignore_glob() {
  local cwd=$PWD
  local ignore=(
    "*.lock"
    "*.log"
    "*.tmp"
    "*_history"
    "*~"
    ".*.log"
    ".\#*"
    "\#*"
    "__*"
    ".tmp.drivedownload"
    ".DS_Store"
    ".rpt2_cache"
    "tmp"
  )

  # if in home directory
  if [[ $cwd == $HOME ]]; then
    ignore+=(
      ".Trash"
      ".CFUserTextEncoding"
      ".iterm2_shell_integration*"
      ".zcompdump*"
    )
  fi

  # if in node project
  if [ -e $cwd/package.json ] || [ -e $cwd/mix.exs ]; then
    ignore+=(
      "node_modules"
      "package-lock.json"
      "yarn-lock.json"
      ".tern-port"
    )
  fi

  # if in git project
  if [ -e $cwd/.git ]; then
    ignore+=(
      ".git"
    )
  fi

  if [[ -e $cwd/mix.exs ]]; then
    ignore+=(
      "_build"
      "deps"
    )
  fi

  test -e $HOME/.gitignore && ignore+=($(cat $HOME/.gitignore | grep -vE '(\#|^$)' | xargs echo))
  test -e $cwd/.gitignore && ignore+=($(cat $cwd/.gitignore | grep -vE '(\#|^$)' | xargs echo))

  # sort globs
  ignore=($(echo ${ignore} | tr ' ' '\n' | sort | uniq | tr '\n' ' '))

  echo "${(j:|:)ignore}"
}

function relpath() {
  [[ $# -ge 1 ]] && [[ $# -le 2 ]] || return 1
  local target=${${2:-$1}:a} # replace `:a' by `:A` to resolve symlinks
  local current=${${${2:+$1}:-$PWD}:a} # replace `:a' by `:A` to resolve symlinks
  local appendix=${target#/}
  local relative=''
  while appendix=${target#$current/}
        [[ $current != '/' ]] && [[ $appendix = $target ]]; do
    if [[ $current = $appendix ]]; then
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
    --ignore-glob "$(get_ignore_glob)" \
    --git-ignore \
    $@
}

# navigation

function cd() {
  tmux_initialize_session_cwd
  builtin cd "$@"
  if [ $? -eq 0 ]; then
    clear
    lsr
    tmux_relative_cwd $PWD
  fi
}

function j() {
  cd ..
}

function k() {
  cd -
}

# search

function tree() {
  /usr/local/bin/tree \
    -I "$(get_ignore_glob)" \
    -C \
    -a \
    --dirsfirst \
    --noreport \
    $@ \
    | more \
        --raw-control-chars \
        --quiet \
        --force
}
