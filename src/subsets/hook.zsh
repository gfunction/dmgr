#
# Hook dot recipe.
# @param $1 Executive mode.
# @param $2... Commands which this function can call.
#
declare -ix REC=0
declare -Ax DMGR_TMP_SCRIPT
DMGR_TMP_SCRIPT=(1 /tmp/dmgr-tmp-script 2 /tmp/dmgr-tmp-script-nested)
readonly DMGR_TMP_SCRIPT

_hook() {
  local line= reg= args= ac= e=
  local mode="null"
  REC=$(($REC + 1))

  if [ $# -le 2 ]; then
    echo "Too few arguments."
    return 1
  fi

  if [ -e $DMGR_TMP_SCRIPT[$REC] ]; then
    echo '' > $DMGR_TMP_SCRIPT[$REC]
  else
    touch $DMGR_TMP_SCRIPT[$REC]
  fi
  chmod 600 $DMGR_TMP_SCRIPT[$REC]

  for e in ${@:3}; do
    ac=$ac$(echo $e |
      sed "s/^ALL$/a/" |
      sed "s/^ECHO$/e/" |
      sed "s/^RUN$/r/" |
      sed "s/^LINK$/l/" |
      sed "s/^UNLINK$/u/" |
      sed "s/^USE$/s/" |
      sed "s/^UNUSE$/n/" |
      sed "s/^REARCH$/c/")
  done

  if [ $REC = 2 ]; then
    echo -e "==> NESTED HOOK <${1}>: ${2}"
  else
    MODE=$1
    echo -e "\x1B[32mHOOK <${1}>: ${2}\x1B[0m"
  fi

  cat $2 | while read line; do _d $line
    if [[ $line =~ "\[[a-z]+\]" ]]; then
      [ $line = "[$1]" ] && mode=$1 || mode="null"
    elif [ $mode != "null" ]; then
      if [[ $line =~ "^ECHO\s" ]]   && [[ $ac =~ "a|e" ]]; then
        echo $line | sed "s/^ECHO/echo/" >> $DMGR_TMP_SCRIPT[$REC]
      elif [[ $line =~ "^RUN\s" ]]      && [[ $ac =~ "a|r" ]]; then
        echo $line | sed "s/^RUN//" >> $DMGR_TMP_SCRIPT[$REC]
      elif [[ $line =~ "^REARCH\s" ]] && [[ $ac =~ "a|c" ]]; then
        e=($(echo $line))
        cmd="s,^REARCH ${e[2]} "${e:2}",_hook ${e[2]} ${2} "${e:2}","
        echo $line | sed $cmd >> $DMGR_TMP_SCRIPT[$REC]
      elif [[ $line =~ "^LINK\s" ]]   && [[ $ac =~ "a|l" ]]; then
        echo $line | sed "s/^LINK/_link/" >> $DMGR_TMP_SCRIPT[$REC]
      elif [[ $line =~ "^UNLINK\s" ]] && [[ $ac =~ "a|u" ]]; then
        echo $line | sed "s/^UNLINK/_unlink/" >> $DMGR_TMP_SCRIPT[$REC]
      elif [[ $line =~ "^USE" ]] && [[ $ac =~ "a|s" ]]; then
        echo $line | sed "s/^USE/_use/" >> $DMGR_TMP_SCRIPT[$REC]
      elif [[ $line =~ "^UNUSE" ]] && [[ $ac =~ "a|n" ]]; then
        echo $line | sed "s/^UNUSE/_unuse/" >> $DMGR_TMP_SCRIPT[$REC]
      elif [[ $line =~ "^(if|elif|else|fi|then|for|do|done)" ]]; then
        echo $line >> $DMGR_TMP_SCRIPT[$REC]
      fi
    fi
  done

  . $DMGR_TMP_SCRIPT[$REC]
  rm -f $DMGR_TMP_SCRIPT[$REC]

  REC=$(($REC - 1))

  [ $REC = 0 ] && MODE=''

  return 0
}
