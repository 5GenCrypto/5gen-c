#!/usr/bin/env bash

set -e

./generate-circuits.sh -o
tar xvf circuits.tgz -C circ-obfuscation
