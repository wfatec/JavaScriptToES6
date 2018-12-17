#!/bin/bash

set -euo pipefail

echo "============== Start deploy ============="

echo "Clean up old site"

rm -rf ./_book

echo "Start to build"

gitbook build

docker-compose up -d

echo "============== End build ============="
