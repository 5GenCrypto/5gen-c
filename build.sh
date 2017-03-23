#!/usr/bin/env bash

set -e

usage () {
    echo "5Gen-C build script"
    echo ""
    echo "Flags:"
    echo "  -d,--debug      Build in debug mode"
    echo "  -c,--clean      Remove build"
    echo "  -h,--help       Print this info and exit"
    exit $1
}

opts=`getopt -o cdh --long clean,debug,help -n 'parse-options' -- "$@"`
if [ $? != 0 ]; then
    echo "Error: failed parsing options"
    usage 1
fi

debug=''

while true; do
    case "$1" in
        -c | --clean )
            rm -rf circuit-synthesis circ-obfuscation
            rm -f generate-circuits.sh circobf.sh
            exit 0
            ;;
        -d | --debug )
            debug='debug'
            shift
            ;;
        -h | --help )
            usage 0
            ;;
        -- ) shift; break ;;
        * ) break ;;
    esac
done

set -x

# mkdir -p build
# builddir=$(readlink -f build)
# echo builddir = $builddir

# export CPPFLAGS=-I$builddir/include
# export CFLAGS=-I$builddir/include
# export LDFLAGS=-L$builddir/lib

pull () {
    path=$1
    url=$2
    branch=$3
    if [ ! -d $path ]; then
        git clone $url $path
    fi
    pushd $path
        git pull origin $branch
        if [ "$4" != "" ]; then
            git checkout $4
        fi
    popd
}

# pull circuit-synthesis https://github.com/spaceships/circuit-synthesis master $circuitsynthesis
# pull circ-obfuscation  https://github.com/5GenCrypto/circ-obfuscation  master $circobfuscation

# pushd circuit-synthesis
# cabal sandbox init
# cabal install
# popd

# pushd circ-obfuscation
# ./build.sh $debug

ln -fs circuit-synthesis/scripts/c2a c2a.sh
ln -fs circuit-synthesis/scripts/c2v c2v.sh
cat > dsl.sh <<'EOF'
#!/usr/bin/env bash

dir=$(dirname $(readlink -f "${BASH_SOURCE[0]}"))
cabaldir=$(readlink -f $dir/circuit-synthesis)

cd $cabaldir

cabal run --verbose=0 -- $@

cd ..
EOF
chmod 755 dsl.sh
ln -fs circuit-synthesis/scripts/generate-circuits.sh
ln -fs circ-obfuscation/circobf.sh
