#!/usr/bin/env bash

dir=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")
circuits=$(readlink -f "$dir/../circ-obfuscation/circuits")
mio=$(readlink -f "$dir/../mio")

circuit="$circuits/point/point_base10.dsl.acirc"

args="--verbose --base 10 --smart --mmap CLT --secparam 80 $circuit"

$mio obf obfuscate $args 2>&1 | tee /tmp/obfuscate.txt
obf_time=$(tail -1 /tmp/obfuscate.txt | cut -d' ' -f3)
obf_size=$(ls -lh "$circuit.obf" | cut -d' ' -f5)
$mio obf evaluate $args 0000000000000000000000000 2>&1 | tee /tmp/evaluate.txt
eval_time=$(cat /tmp/evaluate.txt | grep "evaluate total" | cut -d' ' -f3)

echo ""
echo "*****************************"
echo "* Obf time:  $obf_time"
echo "* Obf size:  $obf_size"
echo "* Eval time: $eval_time"
echo "*****************************"
echo ""
