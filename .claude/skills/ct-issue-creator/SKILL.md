---
name: ct-issue-creator
description: ClickUp 태스크 URL로부터 GitHub Issue 생성. ClickUp 태스크를 읽고, 프로젝트 문서를 분석하여 시니어 개발자 관점의 설계를 포함한 GitHub Issue를 작성.
triggers:
  - ClickUp 태스크
  - GitHub Issue 생성
  - 이슈 생성
  - 작업 설계
  - 태스크 설계
role: architect
scope: planning
output-format: structured
---

# CT-Issue-Creator

ClickUp 태스크 → 프로젝트 문서 분석 → GitHub Issue 생성 워크플로우.

## 사용 조건

**필수 입력**: ClickUp 태스크 URL 또는 태스크 ID
- URL 형식: `https://app.clickup.com/t/{task_id}`
- ID 형식: `86abcdef` (8자리 이상 alphanumeric)

## 워크플로우

```
1. ClickUp 태스크 읽기 (MCP: clickup_get_task)
       ↓
2. 태스크 분석 → 도메인 식별 (frontend / backend / infra)
       ↓
3. **도메인 스킬 호출** (Skill 도구로 ct-frontend / ct-backend / ct-infra 실행)
       ↓
4. 관련 프로젝트 문서 읽기 (@docs)
       ↓
5. 스킬 기반 시니어 개발자 관점 설계 수행
       ↓
6. GitHub Issue 생성 (gh cli)
```

> ⚠️ **중요**: Step 3에서 반드시 해당 도메인의 스킬을 Skill 도구로 호출해야 함.
> 스킬 없이 설계하면 프로젝트 컨텍스트가 부족한 설계가 됨.

## Step 1: ClickUp 태스크 읽기

```
mcp__clickup__clickup_get_task
  task_id: "{extracted_id}"
  subtasks: true
```

**추출 정보**:
- name: 태스크 제목
- description: 상세 내용
- tags: 카테고리/도메인 힌트
- priority: 우선순위
- custom_fields: 추가 메타데이터

## Step 2: 도메인 식별

태스크 내용에서 도메인 키워드 탐지:

| 도메인 | 키워드 | 호출할 스킬 |
|--------|--------|-------------|
| Frontend | UI, 컴포넌트, 페이지, Next.js, React, Monaco, 에디터 | `ct-frontend` |
| Backend | API, 서비스, DB, Spring, Judge0, 엔드포인트, 제출 | `ct-backend` |
| Infra | 배포, Docker, CI/CD, 모니터링, Nginx, SSL | `ct-infra` |

> 복합 도메인 (예: Frontend-Backend 연동)은 주요 도메인 스킬을 먼저 호출하고,
> 필요시 연관 도메인 스킬도 추가 호출.

## Step 3: 도메인 스킬 호출 (필수)

**반드시 Skill 도구를 사용하여 해당 도메인 스킬을 호출**:

```
# Frontend 태스크인 경우
Skill(skill: "ct-frontend")

# Backend 태스크인 경우
Skill(skill: "ct-backend")

# Infra 태스크인 경우
Skill(skill: "ct-infra")
```

### 스킬에서 참조할 정보

**ct-frontend 스킬 호출 시 확인할 것:**
- 기술 스택: Next.js 14+, shadcn/ui, Monaco Editor
- 페이지 구조: app/ 디렉토리 레이아웃
- API 연동 패턴: Base URL, 게스트 토큰 처리
- 결과 노출 정책: 노출 O/X 항목
- 컴포넌트 설계 가이드

**ct-backend 스킬 호출 시 확인할 것:**
- 기술 스택: Spring Boot 3.x, SQLite, In-Memory Queue
- 패키지 구조: controller/service/repository 레이어
- API 엔드포인트 및 응답 형식
- Judge0 연동: Language ID, 상태 매핑
- 제출 상태 머신: QUEUED → RUNNING → DONE

**ct-infra 스킬 호출 시 확인할 것:**
- 아키텍처: Vercel + Single VM
- 서비스 구성: Nginx, Spring Boot, Judge0, SQLite
- 배포 방식: 배포 스크립트, systemd
- 보안 요구사항: SSL, 포트 제한

## Step 4: 프로젝트 문서 읽기

**필수 문서** (항상 읽기):
- `docs/PRD.md` - 제품 요구사항
- `docs/project/MILESTONE.md` - 마일스톤 컨텍스트

**도메인별 추가 문서**:

### Frontend
- `docs/api/API_SPECIFICATION.md` - API 연동 스펙
- `docs/development/CODING_CONVENTION.md` - 코딩 규칙

### Backend
- `docs/api/API_SPECIFICATION.md` - API 명세
- `docs/database/DATA_DICTIONARY.md` - DB 스키마
- `docs/database/ERD.md` - 엔티티 관계
- `docs/judge0/INTEGRATION_GUIDE.md` - Judge0 연동 (실행 관련시)
- `docs/development/CODING_CONVENTION.md` - 코딩 규칙

### Infra
- `docs/architecture/SYSTEM_ARCHITECTURE.md` - 시스템 구조
- `docs/architecture/INFRASTRUCTURE.md` - 인프라 구성

## Step 5: 시니어 개발자 관점 설계 (스킬 기반)

### 설계 관점 (반드시 포함)

1. **목표 정의**: 태스크가 달성해야 할 것
2. **기술적 접근**: 구현 방법 개요
3. **영향 범위**: 변경되는 파일/모듈
4. **의존성**: 선행 작업, 외부 의존성
5. **엣지 케이스**: 고려해야 할 예외 상황
6. **테스트 전략**: 검증 방법

### 도메인별 설계 가이드 (스킬 정보 적극 활용)

**Frontend 설계시** (`ct-frontend` 스킬 필수 참조):
- **컴포넌트 구조**: App Router 기반 페이지/컴포넌트 배치
- **상태 관리**: Context/Zustand 사용 여부
- **API 연동**: Base URL, 게스트 토큰 헤더, 폴링 패턴
- **UI 패턴**: shadcn/ui 컴포넌트 활용, cn() 유틸리티
- **Server/Client 구분**: 'use client' 필요 여부 명시
- **성능**: Monaco Editor lazy loading, Submit 폴링 2초

**Backend 설계시** (`ct-backend` 스킬 필수 참조):
- **레이어 구조**: Controller → Service → Repository 패턴
- **API 엔드포인트**: ApiResponse<T> 형식, Rate Limit 적용 여부
- **Judge0 연동**: Language ID, 리소스 제한, 상태 매핑
- **비동기 처리**: BlockingQueue 기반 Submit 처리
- **트랜잭션**: 조회는 readOnly, 저장은 명시적 트랜잭션
- **검증**: 코드 64KB, 입력 10KB 제한

**Infra 설계시** (`ct-infra` 스킬 필수 참조):
- **아키텍처**: Single VM 구성 (Nginx + Spring Boot + Judge0)
- **보안**: Judge0 포트 localhost only, SSL 필수
- **배포**: deploy.sh 스크립트, systemd 서비스
- **백업**: SQLite 일간 백업
- **모니터링**: 로그 관리, 헬스체크

## Step 6: GitHub Issue 생성

### Issue 템플릿

```bash
gh issue create \
  --title "[{마일스톤}-{도메인}] {태스크 제목}" \
  --body "$(cat <<'EOF'
## 개요

{ClickUp 태스크 내용 요약}

**ClickUp 태스크**: {task_url}

## 목표

- {목표 1}
- {목표 2}

## 설계

### 기술적 접근

{구현 방법 상세}

### 파일 변경 범위

- `path/to/file1` - {변경 내용}
- `path/to/file2` - {변경 내용}

### 의존성

- [ ] {선행 작업 또는 외부 의존성}

## 구현 체크리스트

- [ ] {구현 항목 1}
- [ ] {구현 항목 2}
- [ ] {테스트 항목}

## 엣지 케이스

- {고려해야 할 예외 상황}

## 테스트 전략

- {검증 방법}

## 참고 문서

- [PRD](docs/PRD.md)
- {관련 문서}
EOF
)"
```

### 라벨 매핑

| 도메인 | GitHub 라벨 |
|--------|-------------|
| Frontend | `frontend`, `ui` |
| Backend | `backend`, `api` |
| Infra | `infra`, `devops` |
| Bug | `bug` |
| Feature | `enhancement` |

## 예시

### 입력
```
https://app.clickup.com/t/86cxyz123
```

### 처리 흐름
1. `clickup_get_task(task_id="86cxyz123")`
2. 태스크: "문제 목록 페이지 구현"
3. 도메인: Frontend (키워드: 페이지, UI)
4. **`Skill(skill: "ct-frontend")` 호출** → 기술 스택, 페이지 구조, API 연동 패턴 확인
5. 문서 읽기: PRD, API_SPECIFICATION, CODING_CONVENTION
6. 설계: ct-frontend 스킬 정보 + 문서 기반 컴포넌트 구조 설계
7. GitHub Issue 생성

### 결과 Issue 제목
```
[M2-FE] 문제 목록 페이지 구현
```

## MUST DO

1. **ClickUp 태스크 먼저 읽기** - MCP 사용하여 실제 내용 파악
2. **도메인 식별 → Skill 도구로 스킬 호출** - 반드시 ct-frontend / ct-backend / ct-infra 중 해당 스킬 실행
3. **스킬 정보 적극 활용** - 기술 스택, 패턴, 제약사항을 설계에 반영
4. **프로젝트 문서 충분히 읽기** - 컨텍스트 이해 후 설계
5. **시니어 개발자 관점** - 구현 세부사항, 엣지 케이스, 테스트 포함
6. **GitHub Issue 생성** - gh cli 사용

## MUST NOT DO

1. **태스크 읽기 전 설계 시작** - 추측 금지
2. **스킬 호출 없이 설계** - 반드시 도메인 스킬 먼저 호출
3. **문서 읽기 건너뛰기** - 컨텍스트 필수
4. **단순 복사-붙여넣기** - 설계 없이 태스크 내용만 복사
5. **마일스톤 코드 누락** - Issue 제목에 반드시 포함
6. **스킬 정보 무시** - 기술 스택/패턴 정보를 설계에 반영해야 함

## 관련 스킬 (필수 호출)

| 스킬 | 용도 | 호출 조건 |
|------|------|-----------|
| `ct-frontend` | Frontend 설계: Next.js, shadcn/ui, Monaco Editor 패턴 | UI/페이지/컴포넌트 태스크 |
| `ct-backend` | Backend 설계: Spring Boot, SQLite, Judge0 연동 패턴 | API/서비스/DB 태스크 |
| `ct-infra` | Infra 설계: Docker, Nginx, 배포, 모니터링 패턴 | 배포/인프라/DevOps 태스크 |
| `ct-task` | 마일스톤/작업 코드 체계 | (참조용) |

> **중요**: 도메인이 식별되면 해당 스킬을 Skill 도구로 반드시 호출해야 합니다.
> 스킬 호출 없이 설계하는 것은 금지됩니다.

## 관련 문서

자세한 GitHub Issue 템플릿은 [references/github-issue-template.md](references/github-issue-template.md) 참조.
