#!/usr/bin/env bash

set -e

if [[ $# != 1 && $# != 2 ]]; then
    echo "Usage: aes.sh <secparam> [circuit-dir]"
    exit 1
fi

secparam=$1
circuits=$2
npowers=8
eval=$(python -c "print('0' * 128)")

dir=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")
if [[ $circuits == "" ]]; then
    circuits=$(readlink -f "$dir/../circ-obfuscation/circuits")
fi
mio=$(readlink -f "$dir/../mio")

circuit="${circuits}/aes1r.o2.acirc"

args="--verbose --npowers ${npowers} --smart --mmap CLT --scheme MIFE --secparam ${secparam} ${circuit}"

$mio obf obfuscate $args 2>&1 | tee /tmp/obfuscate.txt
ngates=$(grep "ngates" /tmp/obfuscate.txt | cut -d' ' -f4)
nencodings=$(grep "# encodings" /tmp/obfuscate.txt | cut -d' ' -f4)
kappa=$(grep "\* κ:" /tmp/obfuscate.txt | tr -s ' ' | cut -d' ' -f3)
obf_time=$(grep "obfuscate total" /tmp/obfuscate.txt | cut -d' ' -f3)
obf_size=$(ls -lh "$circuit.obf" | cut -d' ' -f5)
obf_mem=$(grep "memory" /tmp/obfuscate.txt | tr -s ' ' | cut -d' ' -f2)
$mio obf evaluate $args "$eval" 2>&1 | tee /tmp/evaluate.txt
eval_time=$(grep "evaluate total" /tmp/evaluate.txt | cut -d' ' -f3)
eval_mem=$(grep "memory" /tmp/evaluate.txt | tr -s ' ' | cut -d' ' -f2)
rm "${circuit}.obf"

echo ""
echo "*****************************"
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
