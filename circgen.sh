#!/usr/bin/env bash

usage () {
    echo "Usage: circgen.sh [DIR]"
    echo ""
    echo "Generates all circuits, and optionally (if DIR is given) runs the scripts"
    echo "for producing the latex data, putting the results in DIR"
    exit "$1"
}

_=$(getopt -o h --long help)
if [[ $? != 0 ]]; then
    echo "Error: failed parsing option flags"
    usage 1
fi

while true; do
    case "$1" in
        -h | --help )
            usage 0 ;;
        -- ) shift; break ;;
        * ) break ;;
    esac
done

set -e

dir=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")

"$dir"/scripts/generate-circuits.sh -o
tar xvf circuits.tgz -C circ-obfuscation
rm circuits.tgz
if [[ -e "$1" ]]; then
    pushd "$dir"/circobf-scripts/
    ./gen-latex.sh -k -d "$1"
    popd
fi
