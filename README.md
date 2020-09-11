# bbs
## MySQL5.7 바이너리 버전 자동 설치 스크립트
### [1] 사용 방법
`
./install-mysql.sh
`
### [2] Set variables
> 기본적인 변수 설정, MySQL data 디렉토리, MySQL 엔진 디렉토리, MySQL 로그 디렉토리를 설정한다.

> 설치할 버전 : INSTALLFILE="mysql-5.7.31-linux-glibc2.12-x86_64"

> MySQL 엔진 경로 : BASEDIR="/usr/local/mysql"

> MySQL 데이터 : DATADIR="/data"

> MySQL 데이터 디렉토리 경로: MYSQL_DATA="$DATADIR/mysql_data"

> MySQL 임시 디렉토리 경로: TMPDIR="$DATADIR/mysql_tmp"

> MySQL 로그 디렉토리 경로: LOGDIR="$DATADIR/mysql_log"

> MySQL 실행 계정: MYSQL_USER="mysql"

> MySQL PID 파일 생성 경로: MYSQLD_PID_PATH="$DATADIR/mysql_data"

### [3] my.cnf
> my.cnf 파일은 MySQL 디폴트 설정 파일. 그대로 사용해도 무방하지만, 환경에 맞게 수정해서 쓰는 것을 권장

> 기본 경로는 /etc/my.cnf
