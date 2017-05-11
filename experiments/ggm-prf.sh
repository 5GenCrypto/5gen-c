#!/usr/bin/env bash

set -e

if [[ $# != 4 ]]; then
    echo "Usage: ggm-prf.sh <nprgs> <symlen> <keylen> <secparam>"
    exit 1
fi

nprgs=$1
symlen=$2
keylen=$3
secparam=$4
npowers=8
inplen=$(python -c "import math; print('%d' % (math.log(${symlen}, 2) * ${nprgs},))")
eval=$(python -c "print('0' * ${nprgs} * ${symlen})")

dir=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")
circuits=$(readlink -f "$dir/../circ-obfuscation/circuits")
mio=$(readlink -f "$dir/../mio")

circuit="${circuits}/sigma/ggm_sigma_${nprgs}_${symlen}_${keylen}.dsl.acirc"

args="--verbose --npowers ${npowers} --sigma --symlen ${symlen} --smart --mmap CLT --secparam ${secparam} ${circuit}"

$mio obf obfuscate $args 2>&1 | tee /tmp/obfuscate.txt
ngates=$(grep "ngates" /tmp/obfuscate.txt | cut -d' ' -f4)
nencodings=$(grep "# encodings" /tmp/obfuscate.txt | cut -d' ' -f4)
kappa=$(grep "\* κ:" /tmp/obfuscate.txt | tr -s ' ' | cut -d' ' -f3)
obf_time=$(grep "obfuscate total" /tmp/obfuscate.txt | cut -d' ' -f3)
obf_size=$(ls -lh "$circuit.obf" | cut -d' ' -f5)
obf_mem=$(grep "memory" /tmp/obfuscate.txt | tr -s ' ' | cut -d' ' -f2)
$mio obf evaluate $args $eval 2>&1 | tee /tmp/evaluate.txt
eval_time=$(grep "evaluate total" /tmp/evaluate.txt | cut -d' ' -f3)
eval_mem=$(grep "memory" /tmp/evaluate.txt | tr -s ' ' | cut -d' ' -f2)
rm "${circuit}.obf"

echo ""
echo "*****************************"
echo "* n: ............ $inplen"
echo "* |Σ|: .......... $symlen"
echo "* k: ............ $keylen"
echo "* # gates: ...... $ngates"
echo "* # encodings: .. $nencodings"
echo "* κ: ............ $kappa"
echo "* Obf time: ..... $obf_time"
echo "* Obf size: ..... $obf_size"
echo "* Obf mem: ...... $obf_mem"
echo "* Eval time: .... $eval_time"
echo "* Eval mem: ..... $eval_mem"
echo "*****************************"
echo ""
