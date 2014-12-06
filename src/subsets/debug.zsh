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
