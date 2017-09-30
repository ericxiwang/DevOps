Mysql master-slave hot backup setting wizard
version:5.7.x
============
step 1:
Change /etc/my.cnf of master
============
step 2:
Change /etc/my.cnf of slave
============
step 3:
Grant replication right to user 'root'
```
--grant replication slave on *.* to root@x.x.x.x identified by 'xxxxxxx';
```
step 4:
lock database table of master node
```
--FLUSH TABLES WITH READ LOCK;
```
============
step 5:
get status of master node
```
--SHOW MASTER STATUS;
out put as follow
+------------------+----------+--------------+------------------+-------------------+
| File             | Position | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set |
+------------------+----------+--------------+------------------+-------------------+
| mysql-bin.000001 |  646085  |              |                  |                   |
+------------------+----------+--------------+------------------+-------------------+
```
============
step 6:
dump all data from master 
```
--mysqldump --all-databases --master-data -uroot -p > /tmp/dbdump.db
```
============
step 7:
unlock database of master node
```
--unlock tables;
```
============
step 8:
copy dbdump.db to slave node
============
step 9:
grant and set replication on master node
```
--CHANGE MASTER TO MASTER_HOST='10.9.51.70',MASTER_USER='root',MASTER_PASSWORD='Istuary-1118',MASTER_LOG_FILE='mysql-bin.000001',MASTER_LOG_POS=646085;
```
============
step 10:
import data on slave
```
--mysql -uroot -p < /tmp/dbdump.db 
```
============
step 11:
restart mydql and start slave
--start slave
