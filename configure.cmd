extproc sh

d=$(dirname "$0" | tr '\\' /)

n=configure
test -f "$d/$n." || { echo "\`$d/$n' not found !!!"; exit 1; }

export LDFLAGS=-Zhigh-mem

opts="--disable-shared --enable-static"
"$d/$n" $opts "$@" 2>&1 | tee "$n.log"
