#!/bin/bash

set -euo pipefail

export RELEASE_INFO=$(cat /version.info)
echo $RELEASE_INFO
envsubst \
  < /etc/nginx/conf.d/default.conf.template \
  > /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'
