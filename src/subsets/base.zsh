#
# Parse feature list to array format of shellscript.
# @param $1 The list file path.
#
function _parse() {
  echo $(cat $1) | tr -s ',' ' '
}

#
# Parse array to feature list and save it.
# @param $1 The list file path.
# @param $2... An array containing feature names.
#
function _save() {
  echo ${@:2} | tr -s ' ' ',' > $1
}

#
# Get file paths with specific pattern.
# @param $1 Directory.
# @param $2 Pattern.
#
function _get() {
  find $1 | grep -E $2 2>/dev/null
}

#
# Report an error and exit with error status.
# @param $1 An error message.
#
function _reperr() {
  echo $1 && exit 1
}

#
# Bold message font.
# @param $1 Message.
#
function _fbold() {
  echo -e "\033[0;1m${1}\033[0;0m"
}

#
# Check if a list has specific value.
# @param $1 The file name including a list.
# @param $2 The value.
#
function _exist() {
  [[ ${$(_parse $1)[(r)$2]} == ${2} ]] && return 0
  return 1
}

#
# Enforce argument checking.
# @param $1 Argument length.
# @param $2 The condition.
# @param $3 Specified length.
#
function _enforce_arg_chk() {
  if ! eval "[ $(($1 - 1)) $(echo $2 | sed 's/>=/-ge/' | sed 's/=/-eq/') ${3} ]"; then
    echo "Missing arguments."
    return 1
  fi
  return 0
}

#
# Get original parameter options.
# @param $1... The command or function arguments.
#
function _get_options() {
  opts=()

  for i in $@; do
    if [[ $i =~ "^:[a-zA-Z\-_]+" ]]; then
      opts=($i $opts)
    fi
  done

  echo ${opts[@]}
}

#
# Dump a install path.
# @param $1 The destination path.
#
function _dump() {
  echo "$1=$2" >> $DMGR_DUMPDIR/$DMGR_HOOK
}

#
# Print install paths and remove the path from dump file.
#
function _drop() {
  echo $DMGR_DUMPDIR/$MODE
  rm -f $DMGR_DUMPDIR/$MODE
}

#
# Define config paths.
# @param $1... Config paths.
#
function _def() {
  DMGR_CONFPATH=(${@:1} $DMGR_CONFPATH)
}

#
# Add debug prefix to message top.
# #param $1 Message.
#
function _d() {
  local e= c=true

  if [ $DMGR_DEBUGMODE ]; then
    for e in ${@}; do
      if [ $c = true ]; then
        echo -e "\x1B[35mDEBUG\x1B[0m ${e}"
        c=false
      else
        echo -e "\x1B[35m >>> \x1B[0m ${e}"
      fi
    done
  fi
}
