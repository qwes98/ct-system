# Local Development Setup

로컬 개발 환경 설정 가이드입니다.

## 1. 필수 요구사항

### 1.1 시스템 요구사항

| 항목 | 최소 | 권장 |
|------|------|------|
| RAM | 8GB | 16GB |
| 디스크 | 20GB 여유 | 50GB 여유 |
| OS | macOS 12+ / Ubuntu 20.04+ / Windows 10+ (WSL2) |

### 1.2 필수 소프트웨어

| 소프트웨어 | 버전 | 설치 확인 |
|------------|------|-----------|
| Git | 2.30+ | `git --version` |
| Docker | 24.0+ | `docker --version` |
| Docker Compose | 2.20+ | `docker compose version` |
| Node.js | 20 LTS | `node --version` |
| pnpm | 8.0+ | `pnpm --version` |
| Java | 17+ | `java --version` |
| Gradle | 8.0+ | `gradle --version` |

### 1.3 권장 도구

| 도구 | 용도 |
|------|------|
| VS Code | 프론트엔드 개발 |
| IntelliJ IDEA | 백엔드 개발 |
| DBeaver | 데이터베이스 관리 |
| Postman | API 테스트 |
| Insomnia | API 테스트 (대안) |

---

## 2. 설치 가이드

### 2.1 macOS

```bash
# Homebrew 설치 (없는 경우)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 필수 도구 설치
brew install git node pnpm openjdk@17 gradle

# Docker Desktop 설치
brew install --cask docker

# Java 환경변수 설정
echo 'export JAVA_HOME=$(/usr/libexec/java_home -v 17)' >> ~/.zshrc
source ~/.zshrc
```

### 2.2 Ubuntu/Debian

```bash
# 시스템 업데이트
sudo apt update && sudo apt upgrade -y

# Git 설치
sudo apt install -y git

# Node.js 20 LTS 설치
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs

# pnpm 설치
npm install -g pnpm

# Java 17 설치
sudo apt install -y openjdk-17-jdk

# Gradle 설치
sdk install gradle 8.5  # SDKMAN 사용 시

# Docker 설치
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER
# 로그아웃 후 재로그인 필요
```

### 2.3 Windows (WSL2)

```powershell
# 1. WSL2 활성화 (PowerShell 관리자 모드)
wsl --install

# 2. Ubuntu 설치 후 Ubuntu 터미널에서 위 Ubuntu 가이드 따르기

# 3. Docker Desktop 설치
# https://docs.docker.com/desktop/install/windows-install/
# "Use WSL 2 based engine" 옵션 활성화
```

---

## 3. 프로젝트 설정

### 3.1 저장소 클론

```bash
# SSH (권장)
git clone git@github.com:your-org/ct-system.git

# HTTPS
git clone https://github.com/your-org/ct-system.git

cd ct-system
```

### 3.2 프로젝트 구조

```
ct-system/
├── frontend/           # Next.js 프론트엔드
├── backend/            # Spring Boot 백엔드
├── docker/             # Docker 관련 파일
│   └── docker-compose.yml
├── docs/               # 문서
└── scripts/            # 유틸리티 스크립트
```

### 3.3 인프라 실행 (Docker Compose)

```bash
# 인프라 서비스 시작 (PostgreSQL, Redis, Judge0)
docker compose -f docker/docker-compose.yml up -d

# 상태 확인
docker compose -f docker/docker-compose.yml ps

# 로그 확인
docker compose -f docker/docker-compose.yml logs -f judge0-server

# 종료
docker compose -f docker/docker-compose.yml down
```

**서비스 접속 정보:**

| 서비스 | URL/Port | 용도 |
|--------|----------|------|
| PostgreSQL | localhost:5432 | 애플리케이션 DB |
| Redis | localhost:6379 | 캐시/큐 |
| Judge0 API | localhost:2358 | 코드 실행 엔진 |

### 3.4 프론트엔드 설정

```bash
cd frontend

# 의존성 설치
pnpm install

# 환경변수 설정
cp .env.example .env.local

# 개발 서버 실행
pnpm dev
```

**.env.local 예시:**
```env
# API
NEXT_PUBLIC_API_URL=http://localhost:8080/api/v1

# 기타 설정
NEXT_PUBLIC_APP_NAME=CT System
```

**접속:** http://localhost:3000

### 3.5 백엔드 설정

```bash
cd backend

# 환경변수 설정
cp src/main/resources/application-local.yml.example src/main/resources/application-local.yml

# Gradle 빌드
./gradlew build

# 개발 서버 실행
./gradlew bootRun --args='--spring.profiles.active=local'
```

**application-local.yml 예시:**
```yaml
spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/ct_system
    username: ct_user
    password: ct_password

  redis:
    host: localhost
    port: 6379

judge0:
  api-url: http://localhost:2358

logging:
  level:
    com.ctsystem: DEBUG
```

**접속:** http://localhost:8080

### 3.6 전체 실행 스크립트

```bash
# scripts/start-dev.sh
#!/bin/bash

echo "Starting infrastructure..."
docker compose -f docker/docker-compose.yml up -d

echo "Waiting for services to be ready..."
sleep 10

echo "Starting backend..."
cd backend
./gradlew bootRun --args='--spring.profiles.active=local' &
BACKEND_PID=$!

echo "Starting frontend..."
cd ../frontend
pnpm dev &
FRONTEND_PID=$!

echo "Development environment is ready!"
echo "Frontend: http://localhost:3000"
echo "Backend: http://localhost:8080"
echo "Judge0: http://localhost:2358"

# Ctrl+C로 종료 시 정리
trap "kill $BACKEND_PID $FRONTEND_PID; docker compose -f docker/docker-compose.yml down" EXIT
wait
```

---

## 4. 데이터베이스 설정

### 4.1 초기 스키마 생성

```bash
# Flyway 마이그레이션 실행 (Spring Boot 시작 시 자동)
./gradlew bootRun

# 또는 수동 실행
./gradlew flywayMigrate
```

### 4.2 시드 데이터

```bash
# 테스트 데이터 로드
./gradlew bootRun --args='--spring.profiles.active=local,seed'
```

### 4.3 데이터베이스 접속

```bash
# psql CLI
docker exec -it ct-postgres psql -U ct_user -d ct_system

# 또는 DBeaver 등 GUI 도구 사용
# Host: localhost
# Port: 5432
# Database: ct_system
# User: ct_user
# Password: ct_password
```

---

## 5. Judge0 설정

### 5.1 상태 확인

```bash
# Judge0 API 상태 확인
curl http://localhost:2358/about

# 지원 언어 목록
curl http://localhost:2358/languages
```

### 5.2 테스트 실행

```bash
# Python 코드 실행 테스트
curl -X POST http://localhost:2358/submissions \
  -H "Content-Type: application/json" \
  -d '{
    "source_code": "print(\"Hello, World!\")",
    "language_id": 71,
    "stdin": ""
  }'

# 결과 조회 (token 값 사용)
curl http://localhost:2358/submissions/{token}
```

### 5.3 언어 ID 매핑

| 언어 | Language ID |
|------|-------------|
| Python 3 | 71 |
| Java | 62 |
| C++ (GCC) | 54 |
| JavaScript (Node.js) | 63 |

---

## 6. IDE 설정

### 6.1 VS Code (Frontend)

**권장 확장:**
```json
// .vscode/extensions.json
{
  "recommendations": [
    "dbaeumer.vscode-eslint",
    "esbenp.prettier-vscode",
    "bradlc.vscode-tailwindcss",
    "formulahendry.auto-rename-tag",
    "prisma.prisma"
  ]
}
```

**설정:**
```json
// .vscode/settings.json
{
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": "explicit"
  },
  "typescript.preferences.importModuleSpecifier": "non-relative"
}
```

### 6.2 IntelliJ IDEA (Backend)

**권장 플러그인:**
- Lombok
- Spring Boot Assistant
- SonarLint
- CheckStyle-IDEA

**설정:**
1. `File > Project Structure > SDK` → JDK 17 선택
2. `Settings > Build > Gradle` → "Build and run using" Gradle 선택
3. `Settings > Editor > Code Style` → Google Java Style 적용

---

## 7. 테스트 실행

### 7.1 프론트엔드 테스트

```bash
cd frontend

# 단위 테스트
pnpm test

# 테스트 커버리지
pnpm test:coverage

# E2E 테스트 (Playwright)
pnpm test:e2e
```

### 7.2 백엔드 테스트

```bash
cd backend

# 전체 테스트
./gradlew test

# 특정 테스트만
./gradlew test --tests "*SubmissionServiceTest*"

# 커버리지 리포트
./gradlew jacocoTestReport
# 리포트 위치: build/reports/jacoco/test/html/index.html
```

---

## 8. 트러블슈팅

### 8.1 Docker 관련

**문제:** Docker Compose 실행 시 포트 충돌
```bash
# 해결: 사용 중인 포트 확인 및 종료
lsof -i :5432
kill -9 <PID>

# 또는 docker-compose.yml에서 포트 변경
```

**문제:** Judge0 워커가 실행되지 않음
```bash
# 해결: 로그 확인
docker compose logs judge0-workers

# cgroup 관련 문제시
sudo mkdir -p /sys/fs/cgroup/memory/judge0
```

### 8.2 Node.js 관련

**문제:** pnpm install 실패
```bash
# 해결: 캐시 정리 후 재설치
pnpm store prune
rm -rf node_modules
pnpm install
```

### 8.3 Java/Gradle 관련

**문제:** Gradle 빌드 실패
```bash
# 해결: 캐시 정리
./gradlew clean
rm -rf ~/.gradle/caches
./gradlew build
```

**문제:** Java 버전 불일치
```bash
# 해결: JAVA_HOME 확인
echo $JAVA_HOME
java --version

# macOS에서 버전 변경
export JAVA_HOME=$(/usr/libexec/java_home -v 17)
```

### 8.4 데이터베이스 관련

**문제:** PostgreSQL 연결 실패
```bash
# 해결: 컨테이너 상태 확인
docker compose ps
docker compose logs postgres

# 직접 연결 테스트
docker exec -it ct-postgres pg_isready
```

---

## 9. 유용한 명령어 모음

```bash
# 전체 인프라 재시작
docker compose -f docker/docker-compose.yml down
docker compose -f docker/docker-compose.yml up -d

# 데이터 초기화 (볼륨 삭제)
docker compose -f docker/docker-compose.yml down -v

# 프론트엔드 의존성 업데이트
cd frontend && pnpm update

# 백엔드 의존성 업데이트
cd backend && ./gradlew dependencyUpdates

# 코드 포맷팅
cd frontend && pnpm format
cd backend && ./gradlew spotlessApply

# 린트 검사
cd frontend && pnpm lint
cd backend && ./gradlew spotlessCheck
```

---

## 10. 환경별 설정 요약

| 설정 | Local | Development | Production |
|------|-------|-------------|------------|
| DB Host | localhost | dev-db.xxx | prod-db.xxx |
| DB Port | 5432 | 5432 | 5432 |
| Redis Host | localhost | dev-redis.xxx | prod-redis.xxx |
| Judge0 URL | localhost:2358 | dev-judge0.xxx | prod-judge0.xxx |
| Log Level | DEBUG | INFO | WARN |
| CORS Origin | * | dev.xxx.com | xxx.com |
