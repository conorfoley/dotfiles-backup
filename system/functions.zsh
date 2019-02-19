# utility

IGNORE_GLOB=$(
  grep -vE '(^\s*?\#|^\#|^$)' $HOME/.gitignore \
    | sort \
    | uniq \
    | tr '\n' '|' \
    | head --bytes -1
)

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
    --ignore-glob "$IGNORE_GLOB" \
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
    -I "$IGNORE_GLOB" \
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
