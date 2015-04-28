#
# Hook dot recipe.
# @param $1 Executive mode.
# @param $2... Commands which this function can call.
#
declare -ix REC=0
declare -Ax MODE
declare -Ax HOOK
declare -Ax TMP_SCRIPT
TMP_SCRIPT=(1 /tmp/dmgr-tmp-script 2 /tmp/dmgr-tmp-script-nested)
readonly TMP_SCRIPT

#
# Operate rec value.
#
_rec() {
  case $1 in
    'enter') REC=$(($REC + 1));;
    'quit') REC=$(($REC - 1));
  esac
}

#
# Set local environment variales.
# @param $1 env name
# @param $2 env value
#
_set() {
  case $1 in
    'mode') MODE[$REC]=$2 ;;
    'hook') HOOK[$REC]=$2
            DMGR_HOOK=$2 ;;
  esac
}

#
# Get local environment value.
# @param $1 env name
#
_get() {
  case $1 in
    'hook') echo $HOOK[$REC] ;;
    'hookfile') echo $DMGR_HOOKDIR/$HOOK[$REC] ;;
    'scriptfile') echo $TMP_SCRIPT[$REC] ;;
  esac
}

#
# Check if the current hook is nested or not.
# @return true or false
#
_is_nested() {; [ $REC = 2 ]; }

#
# Start and switch to next status.
# @param $1 mode name
# @param $2 hook name
#
_hook_start() {
  _rec enter
  _set mode $1
  _set hook $2

  local script=$(_get scriptfile)

  # Make a new scriptfile or refresh a current scriptfile.
  echo '' > $script

  # Change file name mode for security.
  chmod 600 $script
}

#
# Switch to previous status before finishing hooking.
#
_hook_end() {
  local script=$(_get scriptfile)

  # Load a current scriptfile and remove it.
  . $script
  rm -f $script

  _rec quit
  
  # Revert previous hook name.
  _set hook $(_get hook)
}

#
# Write temporary scripts.
# @param $1 mode
# @param $2 hookfile
#
_write_tmp_script() {
  local line=
  local mode="null"
  local script=$(_get scriptfile)

  cat $2 | while read line; do _d $line
    if [[ $line =~ "\[[a-z]+\]" ]]; then
      [ $line = "[$1]" ] && mode=$1 || mode="null"

    elif [ $mode != "null" ]; then
      if [[ $line =~ "^(if|elif|else|fi|then|for|do|done)" ]] || [[ $line =~ "^[A-Z]+\s" ]]; then
        echo $line >> $script
      fi
    fi
  done
}

#
# Hook handlers.
# @param $1 mode
# @param $2 hook name
#
_hook() {
  _hook_start $1 $2

  local hookfile=$(_get hookfile)

  # The hook function must not be executed under no hookfile.
  if ! [ -e $hookfile ]; then
    echo "No such hookfile. Passed."
    return 200
  fi

  if _is_nested; then
    echo -e "==> NESTED HOOK <${1}>: ${hookfile}"
  else
    echo -e "\x1B[32mHOOK <${1}>: ${hookfile}\x1B[0m"
  fi

  _write_tmp_script $1 $hookfile

  _hook_end

  return 0
}
