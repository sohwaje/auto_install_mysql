# bbs
## MySQL5.7 바이너리 버전 자동 설치 스크립트
### [1] 사용 방법
`
./install-mysql.sh
`
### [2] Set variables
> 기본적인 변수 설정, MySQL data 디렉토리, MySQL 엔진 디렉토리, MySQL 로그 디렉토리를 설정한다.
INSTALLFILE="mysql-5.7.31-linux-glibc2.12-x86_64"
BASEDIR="/usr/local/mysql"
DATADIR="/data"
MYSQL_DATA="$DATADIR/mysql_data"
TMPDIR="$DATADIR/mysql_tmp"
LOGDIR="$DATADIR/mysql_log"
MYSQL_USER="mysql"
MYSQLD_PID_PATH="$DATADIR/mysql_data"
### [3] my.cnf
> my.cnf 디폴트 설정 파일. 그대로 사용해도 무방하지만, 환경에 맞게 수정해서 쓰는 것을 권한한다.
> 기본 경로는 /etc/my.cnf

### [4]
