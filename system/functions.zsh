# utility

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
  local ignore=(
    .\#*
    \#*
    *~
    __*
    *.lock
    *.log
    .*.log
    *.tmp
    *_history
    .DS_Store
    .tern-port
    .git
    package-lock.json
    tmp
    node_modules
  )

  local ignore_glob=${(j:|:)ignore}

  exa \
    --all \
    --group-directories-first \
    --ignore-glob $ignore_glob \
    --long \
    --modified \
    --sort Name \
    --time-style long-iso \
    --git-ignore \
    $@
}

function cat() {
  if [[ $# == 1 && $1 =~ '.md$' ]]; then
    nd $1 2>/dev/null
  else
    /usr/local/bin/gcat "$@"
  fi
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

function gre() {
  local ignored=$(get_ignored)
  local dirs=$(sed -n 1p <<< $ignored)
  local results=$(
    map_to_option '--exclude-dir' $dirs \
      | xargs -J % /usr/bin/grep % $@
  )

  if [ $results ]; then
    while read line; do
      local file=$(cut -d ':' -f1 <<< $line)
      git check-ignore -q $file
      test $? != 0 && echo $line
    done <<< $results
  fi
}

function tree() {
  set -A array
  array+=".git"

  # don't show files that we ignore globally in git
  array+=$(rows_to_list ~/.dotfiles/git/gitignore "|")

  if [ -f .gitignore ]; then
    # don't show files that we ignore locally in git
    array+=$(rows_to_list .gitignore "|")
  fi

  IFS="|"
  /usr/local/bin/tree -I "${array[*]}" -a --dirsfirst $@
  unset $array
}

function get_ignored() {
  local patterns=$(
    cat ~/.dotfiles/git/gitignore \
      | /usr/bin/grep -v '^#'
  )

  patterns+=$(
    find . -maxdepth 3 -name '.gitignore' -type f -exec \
      sed "s,\(.*\),{}\1," {} \; \
        | /usr/bin/grep -v '^#' \
        | sed 's,\.gitignore,,' \
        | sed 's,^\.\/\(.*\),\1,'
  )

  local ignores=''
  local dirs='.git '
  while read f; do
    if [ -d $f ]; then
      dirs+="$f "
    else
      ignores+="$f "
    fi
  done <<< $(tr -s '\n' <<< $patterns)

  echo "$dirs\n$ignores"
}

function map_to_option() {
  local option=$1
  local list=$(tr ' ' '\n' <<< $2)

  echo $list \
    | sed "s,\(.*\),$option=\1," \
    | tr '\n' ' '
}

function rows_to_list() {
  cat $1 \
    | tr "\n" "$2" \
    | tr -s "$2" \
    | sed "s/\(.*\)$2$/\1/"
}
