# MySQL 5.7 자동 설치 스크립트
## MySQL5.7 바이너리 버전 자동 설치 스크립트
### [0] 소개
- 이 스크립트는 CentOS7 환경에서 MySQL5.7 바이너리 버전을 자동으로 설치하는 스크립트입니다.(도커 용도 아닙니다.)
- 이 스크립트는 가상 머신 생성 초기에 실행시켜야 합니다. sudo 패스워드가 없는 상태로 설치해야 하기 때문입니다.
- aws 또는 azure 등에서 가상 머신을 생성할 때 사용하는 user-data.sh에 이 스크립트를 복사해서 설치할 수 있습니다.
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
#
# MySQL v5.7 Auto install script
## MySQL5.7 binary Installation Script
### [0] Introduction
- This script automatically installs the MySQL5.7 binary version in a CentOS7 environment (not for dockers).
- The script must be run early in the creation of the virtual machine. This is because you must install it without a sudo password.
- You can copy and install this script to user-data.sh, which you use to create virtual machines, such as aws or Azure.
- Although mysql is usually heavily used as a docker, this script can install MySQL5.7 at one time via a setup file that has already been customized.
- When this script runs, the MySQL temporary root password is printed at the end. Please change the root password.

### [1] How to use
`
./install-mysql.sh
`
### [2] Description variables
> Set basic variable settings, MySQL data directory, MySQL engine directory, and MySQL log directory.

> installation file :

`
INSTALLFILE="mysql-5.7.31-linux-glibc2.12-x86_64"
`
> MySQL engine path :

`
BASEDIR="/usr/local/mysql"
`
> MySQL installation root dir :

`
DATADIR="/data"
`
> MySQL Data directory path:

`
MYSQL_DATA="$DATADIR/mysql_data"
`
> MySQL Temporary directory path:

`
TMPDIR="$DATADIR/mysql_tmp"
`
> MySQL Log directory path:

`
LOGDIR="$DATADIR/mysql_log"
`
> MySQL execution account:

`
MYSQL_USER="mysql"
`

> MySQL PID path:

`
MYSQLD_PID_PATH="$DATADIR/mysql_data"
`
### [3] my.cnf
- My.cnf files included in this script can be used as they are or modified to suit your environment.

> my.cnf path :

`
/etc/my.cnf
`
