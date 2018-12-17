#!/bin/bash

set -euo pipefail

echo "============== Start deploy ============="

echo "Update source code"

git pull

echo "Start to build"

gitbook build

docker-compose up -d

echo "============== End build ============="
