#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
mkdir -p build evidence
swiftc -DDEMO_MODE ChatGPTDemo/Store.swift scripts/ModelChecks.swift -o build/model-checks
build/model-checks | tee evidence/model-checks.txt
