#/etc/my.cnf of master
#########################################
[mysqld]
datadir=/var/lib/mysql
socket=/var/lib/mysql/mysql.sock
# Disabling symbolic-links is recommended to prevent assorted security risks
symbolic-links=0
log-error=/var/log/mysqld.log
pid-file=/var/run/mysqld/mysqld.pid
log-bin=mysql-bin
server-id=1
#innodb_flush_logc_at_trx_commit=1
#sync_binlog=1
#########################################








#/etc/my.cnf of slave
#########################################
[mysqld]
datadir=/var/lib/mysql
socket=/var/lib/mysql/mysql.sock
# Disabling symbolic-links is recommended to prevent assorted security risks
symbolic-links=0
log-error=/var/log/mysqld.log
pid-file=/var/run/mysqld/mysqld.pid
server-id = 2
skip-slave-start = true
read_only = on
relay-log = relay-bin
relay-log-index = relay-bin.index
#########################################


#operation on master
grant replication slave on *.* to root@10.9.51.71 identified by 'Istuary-1118';
FLUSH TABLES WITH READ LOCK;
SHOW MASTER STATUS;
#record file name of output
#exit mysql cli
mysqldump --all-databases --master-data -uroot -p > /tmp/dbdump.db
#enter master mysql cli
unlock tables;
change master to master_host='x.x.x.x',master_port= 3306, master_log_file='mysql-bin.000001', master_log_pos= xxx,master_user='root',master_password='Istuary-1118';
#copy data file to slave


#operation on slave
mysql -uroot -p < /tmp/dbdump.db
#enter slave cli
start slave
