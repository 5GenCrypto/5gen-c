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
            rm -f c2a.sh c2v.sh dsl.sh generate-circuits.sh circobf.sh
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
        *) break ;;
    esac
done

set -x

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

pull circuit-synthesis https://github.com/spaceships/circuit-synthesis master $circuitsynthesis
pull circ-obfuscation  https://github.com/5GenCrypto/circ-obfuscation  master $circobfuscation

pushd circuit-synthesis
cabal update
cabal sandbox init
cabal install
popd

pushd circ-obfuscation
./build.sh $debug
popd

ln -fs circuit-synthesis/scripts/c2a c2a.sh
ln -fs circuit-synthesis/scripts/c2v c2v.sh
cat > circuit-synthesis.sh <<'EOF'
#!/usr/bin/env bash

dir=$(dirname $(readlink -f "${BASH_SOURCE[0]}"))
progdir=$(readlink -f $dir/circuit-synthesis/.cabal-sandbox/bin)

$progdir/circuit-synthesis $@
EOF
chmod 755 circuit-synthesis.sh
ln -fs circuit-synthesis/scripts/generate-circuits.sh generate-circuits.sh
ln -fs circ-obfuscation/circobf.sh circobf.sh
ln -fs circuit-synthesis/scripts

set +x

echo ""
echo "**************************************************************************"
echo ""
echo "5Gen-C: Build completed successfully!"
echo "* circuit-synthesis ($(cd circuit-synthesis && git rev-parse HEAD))"
echo "* circ-obfuscation  ($(cd circ-obfuscation  && git rev-parse HEAD))"
echo ""
echo "Executables:"
echo "* c2a.sh               :: C2A compiler"
echo "* c2v.sh               :: C2V compiler"
echo "* circuit-synthesis.sh :: DSL and circuit optimizer"
echo "* generate-circuits.sh :: Script for generating all circuits"
echo "* circobf.sh           :: Circuit obfuscation implementation"
echo ""
echo "**************************************************************************"
