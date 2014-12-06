#
# Define config paths.
# @param $1... Config paths.
#
function def() {
  DMGR_CONFPATH=(${@:1} $DMGR_CONFPATH)
}
