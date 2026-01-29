---
name: ct-infra
description: 코딩테스트 연습 플랫폼(ct-system) 인프라 구성 및 배포. Docker, Oracle Cloud, Nginx, CI/CD 관련 작업시 사용.
triggers:
  - ct-system infra
  - Docker Compose
  - Oracle Cloud
  - Nginx 설정
  - 배포
  - 모니터링
role: specialist
scope: implementation
output-format: code
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
---

# CT-Infra: 인프라 스킬

## 비용 목표

**월 1만원 이하** 또는 **완전 무료 (Oracle Cloud Free Tier)**

| 구성 | Frontend | Backend | 월 비용 |
|------|----------|---------|---------|
| Oracle Free | Vercel 무료 | OCI ARM (4 OCPU, 24GB) | **₩0** |
| 저가 VPS | Vercel 무료 | Vultr/Hetzner $5-6 | ~₩7,000 |

## 아키텍처

```
Vercel (Next.js) → Single VM (Nginx + Spring Boot + Judge0 + SQLite)
```

- **Nginx**: 리버스 프록시, SSL 종료 (:80, :443)
- **Spring Boot**: 백엔드 API (:8080)
- **Judge0**: 코드 실행 엔진 (:2358, localhost only)
- **SQLite**: 애플리케이션 DB (파일)

## 핵심 명령어

```bash
# 로컬 개발 - Judge0 시작
docker-compose up -d

# 프로덕션 배포
/opt/scripts/deploy.sh

# 서비스 관리
sudo systemctl restart ct-backend
```

## MUST DO

1. SSL 필수 (Let's Encrypt)
2. Judge0 포트 localhost만 허용
3. 일 1회 SQLite 백업
4. 환경변수로 시크릿 관리

## MUST NOT

1. Judge0 포트 외부 노출 금지
2. 루트 계정 서비스 실행 금지
3. 비밀번호 하드코딩 금지

## 참고 문서

| 문서 | 경로 |
|------|------|
| 인프라 상세 | `docs/architecture/INFRASTRUCTURE.md` |
| 기술 스택 | `docs/architecture/TECH_STACK_DECISION.md` |
| 로컬 설정 | `docs/development/LOCAL_SETUP.md` |
| Judge0 보안 | `docs/judge0/SECURITY_CONFIG.md` |

## 스킬 레퍼런스

| 파일 | 내용 |
|------|------|
| [docker-compose.md](references/docker-compose.md) | 로컬 개발 Docker 설정 |
| [server-setup.md](references/server-setup.md) | 서버 초기화 및 Nginx |
| [deployment.md](references/deployment.md) | 배포 스크립트 및 CI/CD |
| [monitoring.md](references/monitoring.md) | 모니터링 및 백업 |

## 관련 스킬

- `devops-engineer`: CI/CD, 컨테이너화
- `ct-backend`: 백엔드 개발
- `ct-frontend`: 프론트엔드 배포
