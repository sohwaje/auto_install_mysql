#!/bin/sh
### Name    : install-mysql.sh
### Author  : sohwaje
### Version : 2.0
### Date    : 2020-09-17
############################## Set variables ###################################
INSTALLFILE="mysql-5.7.30-linux-glibc2.12-x86_64"
BASEDIR="/usr/local/mysql"
DATADIR="/data"
MYSQL_DATA="$DATADIR/mysql_data"
TMPDIR="$DATADIR/mysql_tmp"
LOGDIR="$DATADIR/mysql_log"
MYSQL_USER="mysql"
MYSQLD_PID_PATH="$DATADIR/mysql_data"
################################## color functions #############################
# Color functions
end="\033[0m"
red="\033[0;31m"
green="\033[0;32m"
yellow="\033[0;33m"
blue="\033[0;34m"

function red {
  echo -e "${red}${1}${end}"
}

function green {
  echo -e "${green}${1}${end}"
}

function yellow {
  echo -e "${yellow}${1}${end}"
}

function blue {
  echo -e "${blue}${1}${end}"
}
######################### MySQL Download site Check ############################
declare -a candidates_address # set in array
candidates_address=( "https://downloads.mysql.com/archives/get/p/23/file/mysql-5.7.30-linux-glibc2.12-x86_64.tar.gz"
"http://ftp.kaist.ac.kr/mysql/Downloads/MySQL-5.7/mysql-5.7.30-linux-glibc2.12-x86_64.tar.gz"
"http://ftp.jaist.ac.jp/pub/mysql/Downloads/MySQL-5.7/mysql-5.7.30-linux-glibc2.12-x86_64.tar.gz" )
url()
{
    if [ ! -z "$1" ]; then
        curl -Is "$1" | grep -w "200\|301\|302" >/dev/null 2>&1
        [ "$?" -eq 0 ] && echo "ok" || echo "fail"
    else
        exit 9
    fi
}
############################## compress indicator ##############################
# usage: tar xvfz *.tar.gz | _extract
_extract(){
  while read -r line; do
    x=$((x+1))
    echo -en "\e[1;36;40m [$x] extracted\r \e[0m"
  done
  yellow "Successfully extracted"
}
############################## progress indicator ##############################
spinner=( Ooooo oOooo ooOoo oooOo ooooO oooOo ooOoo oOooo);
spin(){
  local pid=$!
  # while [ 1 ]
  while [ "$(ps a | awk '{print $1}' | grep $pid)" ];
  do
    for i in "${spinner[@]}"
    do
      echo -ne "\e[1;35;40m\r[$i]\e[0m";
      sleep 0.2;
    done
  done
}
################################################################################
# If you are using CentOS7, the script will run, but if not, stop.
if [ -f /etc/os-release ]; then
  . /etc/os-release
  OS=$(echo $NAME | awk '{print $1}')
  VER=$(echo $VERSION | awk '{print $1}')
  if [[ $OS == "CentOS" ]] && [[ $VER == "7" ]];then
    yellow "[This Machine OS is $OS $VER]"
  else
    red "[Failed : This Machine OS is not $OS $VER.]"
    exit 9
  fi
fi
################# MySQL has a dependency on the libaio library #################
if ! rpm -qa | grep libaio > /dev/null;then
  yellow "libaio was not found. Install libaio"
  sudo yum install -y libaio
else
  yellow "[libaio already installed]"
fi
########################### Create a mysql User and Group ######################
green "[1] Create a mysql User and Group"
# Check mysql group
GROUP=`cat /etc/group | grep mysql | awk -F ':' '{print $1}'`
if [[ $GROUP != $MYSQL_USER ]];then
  sudo groupadd $MYSQL_USER
else
  yellow "[$MYSQL_USER group already exist]"
fi
# Check mysql user
ACCOUNT=`cat /etc/passwd | grep $MYSQL_USER | awk -F ':' '{print $1}'`
if [[ $ACCOUNT != $MYSQL_USER ]];then
  sudo useradd -r -g $MYSQL_USER -s /bin/false $MYSQL_USER
else
  yellow "[$MYSQL_USER user already exits]"
fi
########################### Create a my.cnf into "/etc" ########################
green "[2] Create a my.cnf"
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
datadir = $MYSQL_DATA
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
innodb_data_home_dir = $MYSQL_DATA

innodb_flush_log_at_trx_commit = 1
innodb_io_capacity = 400
innodb_log_buffer_size = 64M
innodb_log_file_size = 512M #1024M
innodb_log_files_in_group = 4
innodb_log_group_home_dir = $MYSQL_DATA
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

################# make mysql dirs if no exits /usr/local/mysql #################
green "[3] Create MySQL Base directory"
sleep 1
if [ ! -d $BASEDIR ];then
  yellow "[$BASEDIR directory dose not exist, Create New $BASEDIR directory]"
else
  yellow "[$BASEDIR directory already exits, recreate New $BASEDIR directory]"
  sudo rm -rf $BASEDIR
fi
################ create mysql DATADIR if no exits /data ########################
green "[4] Create a new mysql $DATADIR"
sleep 1
if [ ! -d $MYSQL_DATA ];then
  yellow "[MySQL directory does not exist, create MySQL directory]"
  # sudo mkdir $DATADIR
  sudo mkdir -p {"$DATADIR","$MYSQL_DATA","$TMPDIR","$LOGDIR","$LOGDIR/mysql_binlog"}
else
  yellow "[MySQL directory does exist]"
fi
############################# create mysql files ###############################
green "[6] Make MySQL files in /usr/local/mysql directory"
sleep 1
if [ ! -f $LOGDIR/mysql.err ];then
  sudo touch {"$LOGDIR/mysql.err","$LOGDIR/general_query.log","$LOGDIR/slowquery.log"}
else
  echo ""
fi
############################# download MySQL 5.7 ###############################
for i in "${candidates_address[@]}"
do
  # url $URL >/dev/null 2>&1
  if [[ $(url $i) == "ok" ]]; then
    # echo "$i Download"
    sudo wget -P /tmp/ "$i" -q & >& /dev/null
    echo -en "\t\e[1;36;40m    Downloading.....\e[0m"
    spin
    echo ""
    break
  else
    red "Cannot download: $i"
  fi
done
################## extract mysql-5.7.31-linux-glibc2.12-x86_64 #################
green "[8] Extracting mysql-5.7"
cd /tmp/ >& /dev/null || { red "[cd failed]"; exit 1; }
sudo tar xvfz $INSTALLFILE.tar.gz 2>&1 | _extract
sudo mv $INSTALLFILE /usr/local/mysql && sudo rm -f $INSTALLFILE.tar.gz
################################# set permission ###############################
sudo chown -R mysql.mysql $BASEDIR && sudo chown -R mysql.mysql $DATADIR

############################### initialize mysql ###############################
initialize_mysql() {
  green "[9] Install MySQL5.7"
  cd $BASEDIR || { red "[cd Failed]"; exit 1; } # cd 명령이 실패하면 ["cd $BASEDIR failed"]를 출력
  sudo ./bin/mysqld --defaults-file=/etc/my.cnf --basedir=$BASEDIR --datadir=$MYSQL_DATA --initialize --user=mysql &
  echo -en "\t\e[1;36;40m    Installing......\e[0m"
  spin  # progress indicator
  echo ""
  wait # 백그라운드 작업이 끝날 때까지 대기
  password=$(grep 'temporary password' $LOGDIR/mysql.err | awk '{print $11}')
  if [[ -z `cat $LOGDIR/mysql.err | grep -i "\[Error\]"` ]];then
    yello "[Installed]"
  else
    red "[Failed]"
    exit 9
  fi
}
########################### Get MySQL temporary password #######################
temp_password() {
  green "[10] MySQL temporary password"
  echo " temporary password is : $password"
}
######################### Create MySQL start/stop script #######################
create_start_script(){
  sudo cp -ar $BASEDIR/support-files/mysql.server /etc/rc.d/init.d/mysql
  # about sed : https://qastack.kr/ubuntu/76808/how-do-i-use-variables-in-a-sed-command
  sudo sed -i 's,^basedir=$,'"basedir=$BASEDIR"','  /etc/rc.d/init.d/mysql
  sudo sed -i 's,^datadir=$,'"datadir=$MYSQL_DATA"',' /etc/rc.d/init.d/mysql

  sudo bash -c "cat << EOF > /etc/systemd/system/mysql.service
[Unit]
Description=MySQL Server
After=network.target

[Service]
Type= forking
ExecStart = /etc/rc.d/init.d/mysql start
ExecStop = /etc/rc.d/init.d/mysql stop

[Install]
WantedBy=multi-user.target
EOF"
}

start_mysql() {
  sudo systemctl daemon-reload && sudo systemctl start mysql && sudo systemctl enable mysql
}

help_usage(){
  echo "#############################################################################################"
  echo "# This password is a temporary password. Please make sure to change your password as below. #"
  echo "# - sudo $BASEDIR/bin/mysql -uroot -p'$password'                                 #"
  echo "# - mysql> alter user 'root'@'localhost' identified by 'PaSSWORD'                           #"
  echo "#############################################################################################"
  echo ""
  echo "Install Success"
  echo ""
}

initialize_mysql
create_start_script
temp_password
start_mysql
help_usage
