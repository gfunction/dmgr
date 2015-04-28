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
    [ $DMGR_DEBUGMODE ] && ln -sv $src $dst || ln -s $src $dst
    _dump link $dst
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
# Unlink symlinks.
# @param $1 Original file path.
#
function _unlink() {
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

#
# Install a plugin.
# @param $1... The plugin name.
#
function _install() {
  dmgrctl-install $@
}

#
# Uninstall a plugin.
# @param $1... The plugin name.
#
function _uninstall() {
  dmgrctl-uninstall $@
}

#
# Copy a file or directory.
# @param $1 The source path.
# @param $2 The destination path.
#
function _copy() {
  cp -r $1 $2
  [ $? = 0 ] && _dump copy $1
}

#
# Echo a message.
#
function _echo() {
  echo ${@:1}
}

#
# Execute a command line
#
function _run() {
  eval ${@:1}
}

#
# Clean using files.
#
function _clean() {
}
