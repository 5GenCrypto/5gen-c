#!/usr/bin/env bash

set -e

base=15
secparam=80

tmp=$(mktemp)
cat <<EOF > "$tmp"
import math
length = 1
while math.log2(${base}**length) < 80:
    length += 1
print('0' * length)
EOF

eval=$(python "$tmp")

dir=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")
circuits=$(readlink -f "$dir/../circ-obfuscation/circuits")
mio=$(readlink -f "$dir/../mio")

circuit="${circuits}/point/point_base${base}.dsl.acirc"

args="--verbose --base ${base} --smart --mmap CLT --secparam ${secparam} ${circuit}"

$mio obf obfuscate $args 2>&1 | tee /tmp/obfuscate.txt
obf_time=$(grep "obfuscate total" /tmp/obfuscate.txt | cut -d' ' -f3)
obf_size=$(ls -lh "$circuit.obf" | cut -d' ' -f5)
obf_mem=$(grep "memory" /tmp/obfuscate.txt | tr -s ' ' | cut -d' ' -f2)
$mio obf evaluate $args $eval 2>&1 | tee /tmp/evaluate.txt
eval_time=$(grep "evaluate total" /tmp/evaluate.txt | cut -d' ' -f3)
eval_mem=$(grep "memory" /tmp/evaluate.txt | tr -s ' ' | cut -d' ' -f2)

echo ""
echo "*****************************"
echo "* Obf time:  $obf_time"
echo "* Obf size:  $obf_size"
echo "* Obf mem:   $obf_mem"
echo "* Eval time: $eval_time"
echo "* Eval mem:  $eval_mem"
echo "*****************************"
echo ""
