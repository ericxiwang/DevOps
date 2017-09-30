#!/bin/bash

count=0
for (( k=0; k<2; k++ ))
do
    check_code=$( curl --connect-timeout 3 -sL -w "%{http_code}\\n" http://localhost/ -o /dev/null )
    if [ "$check_code" != "200" ]; then
        count=$(expr $count + 1)
        sleep 3
        continue
    else
        count=0
        break
    fi
done
if [ "$count" != "0" ]; then
#   /etc/init.d/keepalived stop
    exit 1
else
    exit 0
fi