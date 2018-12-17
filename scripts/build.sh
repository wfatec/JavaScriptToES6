#!/bin/bash

set -euo pipefail

echo "============== Start build ============="

echo "Clean up old build"

rm -rf ./build

echo "Start to build"

# Create .env.local for CI/CD
cat .env \
  | grep = \
  | sort \
  | sed -e 's|REACT_APP_\([a-zA-Z_]*\)=\(.*\)|REACT_APP_\1=NGINX_REPLACE_\1|' \
  > .env.local

yarn build

echo "============== End build ============="
