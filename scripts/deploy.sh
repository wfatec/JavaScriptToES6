#!/bin/bash

set -euo pipefail

export DEPLOY_ENV=$(echo $DEPLOYMENT_GROUP_NAME | cut -d'-' -f2)

cd /home/ubuntu/web

export NGINX_SUB_FILTER=$(cat .env \
  | grep '=' \
  | sort \
  | sed -e 's/REACT_APP_\([a-zA-Z_]*\)=\(.*\)/sub_filter\ \"NGINX_REPLACE_\1\" \"$\{\1\}\";/')

cat ./scripts/nginx/default.conf.template \
  | sed -e "s|LOCATION_SUB_FILTER|$(echo $NGINX_SUB_FILTER)|" \
  | sed 's|}";\ |}";\n\t\t|g' \
  > default.conf.template

docker-compose up -d --build
docker system prune -f

cd -
