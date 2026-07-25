#! /bin/sh

d="$(dirname "$0")"

target=i686-pc-os2-emx

export LDFLAGS=-Zhigh-mem

opts="
    -DCMAKE_INSTALL_PREFIX=/@unixroot/usr/local
    -G Ninja
    -Dosal=cpp11
    -Denable-libinstpatch=0
"

if [ -n "$1" ] && [ "${1#-}" = "$1" ]; then
    # $1 is a build dir
    [ -f "$1/CMakeLists.txt" ] \
        && { echo "BUILD dir should be different from SOURCE dir!!!"; exit 1; }

    blddir="$1"
    shift
else
    # $1 is empty or an option. Determine the build dir with CMakeLists.txt
    [ -f CMakeLists.txt ] && blddir=build || blddir=.
fi

srcdir="$d"

[ -z "$OS2_SHELL" ] && opts="$opts -DCMAKE_TOOLCHAIN_FILE=\"$d/$target.cmake\""

eval 'cmake -B "$blddir" -S "$srcdir"' $opts '"$@"'
