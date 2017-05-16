#!/usr/bin/env bash

set -e

if [[ $# != 1 && $# != 2 ]]; then
    echo "Usage: ggm-prf-all.sh <secparam> [circuit-dir]"
    exit 1
fi

dir=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")
script="${dir}/ggm-prf.sh"
secparam=$1
circdir=$2
if [[ $circdir == "" ]]; then
    circdir="$dir/../circ-obfuscation"
else
    mkdir -p "$circdir"
    cp -r "$(readlink -f "$dir/../circ-obfuscation/circuits")" "$circdir"
fi
circdir="$circdir/circuits"

echo "*************"
echo "* 8 256 [1] *"
echo "*************"
$script 1 256  32 "${secparam}" "$circdir"
$script 1 256  64 "${secparam}" "$circdir"
$script 1 256 128 "${secparam}" "$circdir"
echo "*************"
echo "* 8  16 [2] *"
echo "*************"
$script 2 16  32 "${secparam}" "$circdir"
$script 2 16  64 "${secparam}" "$circdir"
$script 2 16 128 "${secparam}" "$circdir"
echo "*************"
echo "* 12 64 [2] *"
echo "*************"
$script 2 64  32 "${secparam}" "$circdir"
$script 2 64  64 "${secparam}" "$circdir"
$script 2 64 128 "${secparam}" "$circdir"
