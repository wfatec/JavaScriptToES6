#!/bin/bash

echo "============== Start deploy ============="

echo "Update source code..."

git pull

echo "Clear old container..."

docker container rm -f  JavaScriptToES6

echo "Start server..."

docker run -p 4000:4000 -d --name JavaScriptToES6 -v /root/workspace/JavaScriptToES6/:/srv/gitbook fellah/gitbook

echo "============== End deploy ============="
