#!/bin/sh
## Set variables
INSTALLFILE="mysql-5.7.31-linux-glibc2.12-x86_64z"
BASEDIR="/usr/local/mysql"
DATADIR="/data/mysql_data"
TMPDIR="/data/mysql_tmp"
LOGDIR="/data/mysql_log"
MYSQL_USER="mysql"

# Create a mysql user
sudo groupadd $MYSQL_USER
useradd -r -g $MYSQL_USER -s /bin/false $MYSQL_USER

# Create a my.cnf in "/etc" dir
sudo bash -c "echo '# 4Core 8GB
[client]
port            = 3306
socket          = /tmp/mysql.sock
#default-character-set = utf8mb4

[mysqld]
port            = 3306
socket          = /tmp/mysql.sock
#default-character-set = utf8mb4

basedir = $BASEDIR
datadir = $DATADIR
tmpdir = $TMPDIR

## default
back_log = 450
max_connections = 4510
interactive_timeout = 28800
connect_timeout = 10
wait_timeout = 14400

skip-external-locking
skip-host-cache
skip-name-resolve
explicit_defaults_for_timestamp = 1
lower_case_table_names=1
ft_min_word_len = 2

## Character set
character-set-client-handshake = FALSE
character-set-server = utf8mb4
init_connect = \"set collation_connection=utf8mb4_unicode_ci\"
init_connect = \"set names utf8mb4 collate utf8mb4_unicode_ci\"
collation-server = utf8mb4_unicode_ci

## Connections
max_connections = 200
max_connect_errors = 10000
max_allowed_packet = 16M #1024M
open_files_limit = 65535

## Sesiion
thread_stack = 512K
sort_buffer_size = 4M
read_buffer_size = 4M
join_buffer_size = 4M
read_rnd_buffer_size = 4M
max_heap_table_size = 128M
tmp_table_size = 1024M

## Query Cache Disable
query_cache_type = 0
query_cache_size = 0
query_cache_limit = 0

## Logging
log_error = $LOGDIR/mysql.err
log-warnings = 2
log-output = FILE
log_timestamps = SYSTEM
general_log = 0
general_log_file = $LOGDIR/general_query.log
slow_query_log = 1
slow_query_log_file = $LOGDIR/slowquery.log
long_query_time = 10

## MySQL Metric
innodb_monitor_enable = all
log_slow_admin_statements = ON
#log_slow_slave_statements = ON

## Replication related settings
server-id = 1
slave_parallel_type = LOGICAL_CLOCK
slave_parallel_workers = 0

log-bin=$LOGDIR/mysql_binlog/mysql-bin
binlog_format = ROW
max_binlog_size = 1G
expire_logs_days = 3
#relay_log=$LOGDIR/mysql_binlog/mysql-relay
#read_only = 1
sysdate-is-now
sync_binlog = 1
binlog_cache_size = 16M
#relay_log_purge = ON

## Transaction Isolation Config
transaction-isolation=READ-COMMITTED

## Default Table Settings
#sql_mode =

## Performance Schema Config
performance_schema=1

## Table cache settings
table_open_cache = 80000
table_definition_cache = 4000
group_concat_max_len = 10M

## InnoDB Config
innodb_adaptive_hash_index = 1
innodb_buffer_pool_size = 4G #200G
innodb_data_file_path = ibdata1:100M;ibdata2:100M;ibdata3:100M:autoextend #ibdata1:20G;ibdata2:20G;ibdata3:1G:autoextend
innodb_file_per_table
innodb_data_home_dir = $DATADIR

innodb_flush_log_at_trx_commit = 1
innodb_io_capacity = 400
innodb_log_buffer_size = 64M
innodb_log_file_size = 512M #1024M
innodb_log_files_in_group = 4
innodb_log_group_home_dir = $DATADIR
innodb_thread_concurrency = 0
innodb_write_io_threads = 12
innodb_read_io_threads = 12
innodb_sort_buffer_size = 1M
innodb_print_all_deadlocks = 0

innodb_flush_method = O_DIRECT
innodb_file_format = Barracuda
innodb_file_format_max = Barracuda
innodb_open_files = 80000

## MyISAM Config
key_buffer_size = 8M #32M
bulk_insert_buffer_size = 8M #32M
myisam_sort_buffer_size = 128M
myisam_max_sort_file_size = 512M #10G
myisam_repair_threads = 1

[mysqldump]
quick
max_allowed_packet = 16M #1024M
#default-character-set = utf8mb4

[mysqld_safe]
open-files-limit = 65535
' > /etc/my.cnf"
# Decom MySQL binary file
sudo tar xvfz $INSTALLFILE.tar.gz; \
  sudo mv $INSTALLFILE /usr/local/mysql

# make mysql dirs
sudo mkdir -p $BASEDIR; \
  sudo mkdir -p $DATADIR; \
  sudo mkdir -p $TMPDIR; \
  sudo mkdir -p $LOGDIR; \
  sudo mkdir -p $LOGDIR/mysql_binlog

# make mysql files
sudo touch $LOGDIR/mysql.err; \
  sudo touch $LOGDIR/general_query.log; \
  sudo touch $LOGDIR/slowquery.log

sudo chown -R mysql.mysql $BASEDIR && sudo chown -R mysql.mysql $DATADIR && sudo chown -R mysql.mysql $TMPDIR && chown -R mysql.mysql $LOGDIR

# install mysql
sudo cd $BASEDIR && ./bin/mysqld --basedir=$BASEDIR --datadir=$DATADIR --initialize --user=mysql
wait
if [ $? -eq 0 ];then
  echo "OK"
  password=$(grep 'temporary password' $LOGDIR/mysql.err | awk '{print $11}')
else
  echo "Failed"
  exit 9
fi

# start mysql
sudo cd $BASEDIR && ./bin/mysqld_safe --defaults-file=/etc/my.cnf --user=mysql&
# get a MySQL temporary password
