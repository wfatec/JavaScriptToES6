#!/bin/bash

set -euo pipefail

echo "============== Start deploy ============="

echo "Clean up old site"

rm -rf ./site

echo "Start to build"

gitbook build --output=/site/JavaScriptToES6

docker-compose up -d

echo "============== End build ============="
