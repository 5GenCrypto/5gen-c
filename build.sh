#!/usr/bin/env bash

set -e

usage () {
    echo "5Gen-C build script"
    echo ""
    echo "Flags:"
    echo "  --no-cxs        Do not build cxs"
    echo "  -d,--debug      Build in debug mode"
    echo "  -c,--clean      Remove build"
    echo "  -h,--help       Print this info and exit"
    exit "$1"
}

_=$(getopt -o cdh --long clean,debug,help) # -n 'parse-options' # -- "$@"
if [ $? != 0 ]; then
    echo "Error: failed parsing options"
    usage 1
fi

cxs=1
debug=''

while true; do
    case "$1" in
        -c | --clean )
            rm -rf circuit-synthesis circ-obfuscation
            rm -f c2a.sh c2v.sh dsl.sh generate-circuits.sh mio cxs
            exit 0
            ;;
        -d | --debug )
            debug='debug'; shift ;;
        --no-cxs )
            cxs=0; shift ;;
        -h | --help )
            usage 0
            ;;
        -- ) shift; break ;;
        *) break ;;
    esac
done

set -x

pull () {
    path=$1
    url=$2
    branch=$3
    if [ ! -d "$path" ]; then
        git clone "$url" "$path"
    fi
    pushd "$path"
    git pull origin "$branch"
    if [ x"$4" != x"" ]; then
        git checkout "$4"
    fi
    popd
}


if [[ $cxs == 1 ]]; then
    pull circuit-synthesis https://github.com/spaceships/circuit-synthesis master # $circuitsynthesis
fi
pull circ-obfuscation  https://github.com/5GenCrypto/circ-obfuscation  master # $circobfuscation

if [[ $cxs == 1 ]]; then
    pushd circuit-synthesis
    cabal update
    cabal sandbox init
    cabal install
    cabal build
    popd
fi
    
pushd circ-obfuscation
./build.sh $debug
popd

if [[ $cxs == 1 ]]; then
    ln -fs circuit-synthesis/dist/build/circuit-synthesis/circuit-synthesis cxs
    # Needs to be called scripts as cxs hardcodes those paths
    ln -fs circuit-synthesis/scripts scripts
fi
ln -fs circ-obfuscation/mio.sh mio
ln -fs circ-obfuscation/scripts mio-scripts

set +x

echo ""
echo "**************************************************************************"
echo ""
echo "5Gen-C: Build completed successfully!"
if [[ $cxs == 1 ]]; then
    echo "* circuit-synthesis ($(cd circuit-synthesis && git rev-parse HEAD))"
fi
echo "* circ-obfuscation  ($(cd circ-obfuscation  && git rev-parse HEAD))"
echo ""
echo "Executables:"
echo "* mio                  :: circuit-based MIFE / obfuscation"
if [[ $cxs == 1 ]]; then
    echo "* cxs                  :: circuit synthesis"
    echo "* circgen              :: generate circuits"
fi
echo ""
echo "Directories:"
if [[ $cxs == 1 ]]; then
    echo "* scripts              :: scripts for cxs"
fi
echo "* mio-scripts          :: scripts for mio"
echo ""
echo "**************************************************************************"
