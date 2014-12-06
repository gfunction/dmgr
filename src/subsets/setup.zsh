function _link_script() {
  for dst in dmgr dmgr.debug dmgrctl dmgrctl.debug; do
    ln -sv $HOME/.dmgr/src/dmgr $HOME/bin/$dst
  done
}

function _unlink_script() {
  for dst in dmgr dmgr.debug dmgrctl dmgrctl.debug; do
    rm -fv $HOME/bin/$dst
  done
}

function _link_repo() {
  ln -sv $DMGR_SETUP_DIRNAME/core $HOME/.dmgr
  echo $DMGR_SETUP_DIRNAME > $HOME/.dmgr/paths/_repo
}

function _unlink_repo() {
  rm -fv $HOME/.dmgr/paths/_repo $HOME/.dmgr
}
