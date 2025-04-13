#!/bin/bash
set -euo pipefail

HOST=$(hostname)
WORK="/labdata"
SSH="/labdata/ssh"
NGINX_CONF="/etc/nginx/conf.d/default.conf"
MDB_CONF="/etc/my.cnf.d/server.cnf"
NFS_EXPORTS="/etc/exports"

# /etc/hosts 등록
echo "hosts에 각 서버를 등록합니다."
cat << EOF > /etc/hosts
127.0.0.1   localhost
::1         localhost
10.18.1.91  cent1
10.18.1.92  cent2
10.18.1.93  cent3
EOF

# fstab 등록 (NFS mount용)
echo "fstab에 nfs 정보를 등록합니다."
echo "10.18.1.93:/nfs   /mnt   nfs   nfsvers=3,tcp,nolock,noauto  0  0" >> /etc/fstab

# .bashrc 환경 설정
{
  echo "HISTTIMEFORMAT='## %Y-%m-%d %T ## '"
  echo "alias ls='ls --color=tty'"
  echo "alias vi='vim'"
  echo "alias ssh='ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null '"
} >> /root/.bashrc

# SSH 설정
mkdir -p /root/.ssh
cp -rfp ${SSH}/* /root/.ssh/
chmod 600 /root/.ssh/id_rsa || true
chmod 644 /root/.ssh/authorized_keys || true

# Login 메시지
cat << 'EOF' >> /root/.bashrc

echo ""
echo "---------------------------------------------------------------------"
echo "이 서버는 학습용 가상회사인 Virtual Web Service Company의 서버입니다."
echo ""
echo "실습의 용이성을 위해 selinux와 iptables를 off 했습니다."
echo ""
echo "root 유저로 접속했습니다. 이대로 실습을 진행해 주세요."
echo "---------------------------------------------------------------------"
echo ""

EOF

# 서버 역할별 처리
case ${HOST} in
  cent1)
    echo "[cent1] 웹 서버 준비 중..."
  
    # nginx 전체 설정 덮어쓰기
    if [ -e ${WORK}/nginx.conf ]; then
      echo "[cent1] nginx.conf 전체 덮어쓰기..."
      cp -fvp ${WORK}/nginx.conf /etc/nginx/nginx.conf
    else
      echo "[cent1] nginx.conf 파일이 존재하지 않습니다."
    fi
  
    # 웹 소스 압축 해제
    if [ -e ${WORK}/web_src.tgz ]; then
      echo "[cent1] 웹 소스 복사 중..."
      mkdir -p /usr/share/nginx/html
      tar xzf ${WORK}/web_src.tgz -C /usr/share/nginx/html --strip-components=1
    else
      echo "[cent1] web_src.tgz 파일이 존재하지 않습니다."
    fi
  
    # nginx 시작
    echo "[cent1] nginx 실행"
    /usr/sbin/nginx
  
    ;;

  cent2)
    echo "[cent2] DB 서버 준비 중..."
    mysqld_safe --datadir=/var/lib/mysql &
    sleep 5
    if [ ! -d "${WORK}/test_db" ]; then
      git clone https://github.com/t2sc0m/test_db.git ${WORK}/test_db
    fi
    mysql -uroot < ${WORK}/test_db/employees.sql || true
    ;;

  cent3)
    echo "[cent3] NFS 서버 준비 중..."

    # /nfs 디렉터리 생성 + 권한 설정
    mkdir -p /nfs
    chmod 755 /nfs

    # /etc/exports 복사
    [ -e ${WORK}/exports ] && cp -fvp ${WORK}/exports ${NFS_EXPORTS}

    # NFS 관련 데몬 실행
    rpcbind
    exportfs -a
    /usr/sbin/rpc.nfsd
    /usr/sbin/rpc.mountd -F &
    ;;

  *)
    echo "⚠️ 알 수 없는 HOST: ${HOST}"
    ;;
esac

# 공통 SSH 설정
if [ ! -f /etc/ssh/ssh_host_rsa_key ]; then
  echo "[${HOST}] SSH 호스트 키 생성 중..."
  ssh-keygen -A
fi

# SSH 데몬 실행
/usr/sbin/sshd

# 컨테이너 종료 방지
exec tail -f /dev/null

