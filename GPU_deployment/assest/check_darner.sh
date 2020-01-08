#/bin/bash
output=`(#sleep 1;
echo "stats";
sleep 1;
) | telnet localhost 22133 | grep 'STAT version' | awk {' print $3 '}`

if [ "$output" == "0.2.0" ];then
status=1
else
status=0
fi
echo $status
