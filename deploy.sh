#!/bin/bash

echo "============== Start deploy ============="

echo "Start to server"

docker run -p 4000:4000 -d -v /root/workspace/JavaScriptToES6/:/srv/gitbook fellah/gitbook

echo "============== End build ============="
