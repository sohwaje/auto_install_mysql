# bbs
## MySQL5.7 바이너리 버전 자동 설치 스크립트
### [0] 소개
- 이 스크립트는 MySQL5.7 바이너리 버전을 자동으로 설치하는 스크립트입니다.
- 이 스크립트는 가상 머신 생성 초기에 실행시켜야 합니다. sudo 패스워드가 없는 상태로 설치해야 하기 때문입니다.
- aws 또는 azure 등에서 가상 머신을 생성할 때 사용하는 user-data.sh에 이 스크립트를 복사해서 설치하기를 권장합니다.
- 보통 docker로 mysql을 많이 쓰지만, 이 스크립트는 이미 커스텀된 설정 파일을 통해 한번에 MySQL5.7을 설치할 수 있습니다.
- 이 스크립트가 실행되면, 마지막에 MySQL 임시 루트 패스워드가 출력됩니다. 반드시 루트 패스워드를 변경해주세요.

### [1] 사용 방법
`
./install-mysql.sh
`
### [2] Set variables
> 기본적인 변수 설정, MySQL data 디렉토리, MySQL 엔진 디렉토리, MySQL 로그 디렉토리를 설정합니다.

> 설치 파일 :

`
INSTALLFILE="mysql-5.7.31-linux-glibc2.12-x86_64"
`
> MySQL 엔진 경로 :

`
BASEDIR="/usr/local/mysql"
`
> MySQL 데이터 :

`
DATADIR="/data"
`
> MySQL 데이터 디렉토리 경로:

`
MYSQL_DATA="$DATADIR/mysql_data"
`
> MySQL 임시 디렉토리 경로:

`
TMPDIR="$DATADIR/mysql_tmp"
`
> MySQL 로그 디렉토리 경로:

`
LOGDIR="$DATADIR/mysql_log"
`
> MySQL 실행 계정:

`
MYSQL_USER="mysql"
`

> MySQL PID 파일 생성 경로:

`
MYSQLD_PID_PATH="$DATADIR/mysql_data"
`
### [3] my.cnf
- my.cnf 파일은 MySQL 디폴트 설정 파일. 그대로 사용해도 무방하지만, 환경에 맞게 수정해서 쓰는 것을 권장합니다.

>기본 경로 :

`
/etc/my.cnf
`
