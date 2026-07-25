extproc sh

d=$(dirname "$0" | tr '\\' /)

n=cmkconf.sh
test -f "$d/$n." || { echo "\`$d/$n' not found !!!"; exit 1; }

opts=""

eval '"$d/$n"' $opts '"$@" 2>&1 | tee "$(basename "$n.log")"'
exit ${PIPESTATUS[0]}
