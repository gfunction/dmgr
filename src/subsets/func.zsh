#
# Link symlinks.
#
function _link() {
  local src= dst=
  
  if [ $# -le 2 ]; then
    src=$(eval "echo $1" | sed "s,@,${DMGR_REPODIR}/common/,")
    if [ $# -eq 2 ]; then
      dst=$(eval "echo ${2}")
    else
      dst=$HOME/.$(echo $1 | sed "s/@//")
    fi
    [ $DMGR_DEBUGMODE ] &&
      ln -sv $src $dst || ln -s $src $dst
  else
    echo "Too many arguments."
    return 1
  fi

  return 0
}

#
# Unlink symlinks.
# @param $1 Original file path.
#
function _unlink() {
  declare -a lns
  local e=

  if [ $# -ge 2 ]; then
    echo "Too many arguments."
    return 1
  fi

  [ "${LISTS}" = "" ] && LISTS=$(find $HOME -ls)

  lns=($(echo $LISTS |
  grep -oE "/.*\s\->.*$" |
  tr -s " \-> " "," |
  grep -E $(echo $(eval "echo $1" | sed "s,@,${DMGR_REPODIR}/common/,") | sed "s,\.,\\\.,g")"$" |
  sed "s,\,.*,,g"))

  for e in $lns; do
    [ $DMGR_DEBUGMODE ] &&
      rm -v $e || rm $e
  done

  return 0
}

#
# Make symlinks for scripts in ./bin
# @param $1... The script name.
#
function _use() {
  local e=

  for e in $(echo $@ | tr -s ',' ' '); do
    if [ ! -e $DMGR_REPODIR/bin/$e ]; then
      echo "${e} is not found."
      continue
    else
      ln -s $DMGR_REPODIR/bin/$e $HOME/bin/$e
    fi
  done
}

# Remove symlinks from ~/bin
# @param $1... The script name.
#
function _unuse() {
  local e=

  for e in $(echo $@ | tr -s ',' ' '); do
    if [ ! -e $HOME/bin/$e ]; then
      echo "${e} is not found."
      continue
    else
      rm -f $HOME/bin/$e
    fi
  done
}
