#!/bin/bash

echo "============== Start deploy ============="

echo "Update source code..."

git pull

echo "Start server..."

docker run -p 4000:4000 -d -v /root/workspace/JavaScriptToES6/:/srv/gitbook fellah/gitbook

echo "============== End deploy ============="
