CHECK_COUNT=5
 
counter=1
while true
do
        status=$(systemctl is-active mysqld)
        if [ $status = 'active' ] 
        then
                exit 0
        else
                if [ $i = 1 ] && [ $j = 0 ]
                then
                        exit 0
                else
                        if [ $counter -gt $CHECK_COUNT ]
                        then
                                break
                        fi
                let counter++
                continue
                fi
        fi
        done
systemctl stop keepalived
exit 1
