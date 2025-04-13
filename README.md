# Bash Shell Script 실습 환경

---

## 1. 프로젝트 개요

이 프로젝트는 Bash ShellScript 실전편 실습용으로 가상 기업 **Virtual Web Service Company**의 인프라 실습 환경을 Docker 기반으로 구현한 것입니다.
기존 Vagrant 환경의 복잡함을 제거하고, 누구나 쉽게 실습할 수 있도록 구성했습니다.

---

## 2. 컨테이너 구성

| 컨테이너 | 역할       | 서비스       | IP (DMZ)     |
|----------|------------|--------------|--------------|
| cent1    | 웹 서버    | nginx        | 172.18.1.91  |
| cent2    | DB 서버    | MariaDB 10.4 | 172.18.1.92  |
| cent3    | 스토리지   | NFS 서버     | 172.18.1.93  |

---

## 3. 사전 준비 사항

- Docker 설치 (https://www.docker.com/products/docker-desktop)
- Docker Compose 설치 (v2.x 권장)
- Git 설치 (https://git-scm.com)

※ 각 소프트웨어의 설치 방법은 해당 링크의 공식 문서를 참고해 주세요.  
  (Windows, macOS, Linux 환경 모두 지원됩니다.)

---

## 4. 사용 방법

### 4-1. 저장소 클론

```bash
git clone https://github.com/bashbomb/VWS-docker-environment.git
```

### 4-2. 컨테이너 이미지 빌드

```bash
cd VWS-docker-environment
docker-compose build
```

### 4-3. 컨테이너 실행

```bash
docker-compose up -d
```

### 4-4. 로컬 환경에서 컨테이너에 접속

```bash
# 웹 서버에 접속
docker exec -it cent1 bash
# DB 서버에 접속
docker exec -it cent2 bash
# 스토리지 서버에 접속
docker exec -it cent3 bash
```

### 4-5. 컨테이너 내부에서 다른 서버에 접속

각 컨테이너에는 `/root/.ssh/config`와 키 파일이 미리 설정되어 있어
컨테이너 내부에서 이름(`cent1`, `cent2`, `cent3`)만으로 SSH 접속이 가능합니다.

예시:

```bash
# cent2 또는 cent3에서 cent1에 접속
ssh cent1 
# cent1, 3에서 cent2에 접속
ssh cent2 
# cent1, 2에서 cent3에 접속
ssh cent3 
```

---

## 5. 웹 페이지 접속

- 브라우저에서 접속: [http://localhost](http://localhost)
- cent1 컨테이너의 `/usr/share/nginx/html` 디렉터리에 있는 웹소스가 서비스됩니다.
- 기본적으로 `index.html` 파일이 포함되어 있으며, 실습 시 자유롭게 수정 가능합니다.

---

## 6. 실습 가능한 주요 항목

- 컨테이너 간 SSH 통신 (`ssh cent2`, `ssh cent3`)
- MariaDB 접속 및 데이터베이스 테스트 (`mysql -uroot`)
- NFS 서버에서 export, 다른 서버에서 mount (`mount /mnt`)
- 웹서버 기본 페이지 확인
- 시스템 부하 테스트 (`stress`), 기본 커맨드 (`ps`, `netstat`, `tree` 등)

---

## 7. 참고 및 주의사항

### ✅ Mac(M1/M2/M3)에서 `ps`, `netstat` 실행 시 "rosetta"로 표시됨

- Apple Silicon은 ARM 기반으로, x86 컨테이너는 **Rosetta 2**로 에뮬레이션됩니다.
- 이 때문에 프로세스명이 실제 서비스가 아닌 `/run/rosetta/rosetta`로 표시될 수 있습니다.
- nginx, sshd, mariadb 등은 실제로 정상 실행되고 있으니 무시하셔도 됩니다.

---

## 8. FAQ

### Q. 컨테이너를 모두 초기화하고 싶어요.

```bash
docker-compose down -v --remove-orphans
```

### Q. 다시 빌드하고 싶어요.

```bash
docker-compose build --no-cache
```

---

## 📄 라이선스

본 프로젝트는 [CC BY-NC 4.0 라이선스](https://creativecommons.org/licenses/by-nc/4.0/)에 따라 제공되며,
**비영리** 용도로 자유롭게 사용 가능합니다.
자세한 내용은 LICENSE 파일을 확인해주세요.
