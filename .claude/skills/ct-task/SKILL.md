---
name: ct-task
description: CT-System 프로젝트 작업/마일스톤 관리. 작업 코드 조회, 진행 상황 추적, 다음 작업 결정시 사용.
triggers:
  - 다음 작업
  - 마일스톤
  - M0, M1, M2, M3, M4, M5, M6
  - 작업 진행
  - WBS
  - task breakdown
role: coordinator
scope: planning
output-format: structured
---

# CT-System Task Management

MVP 개발 작업 관리 및 마일스톤 추적.

## 작업 코드 체계

```
[M#]-[영역]-[순번]

M#: M0(셋업) → M1(백엔드) → M2(프론트) → M3(Judge0) → M4(통합) → M5(QA) → M6(출시)
영역: INFRA, BE, FE, QA, PERF, SEC, DEPLOY, OPS
순번: 001-999
```

**예시**: `M2-FE-031` = 마일스톤 2, 프론트엔드, Monaco Editor 설치

## 마일스톤 요약

| 마일스톤 | 내용 | 주요 산출물 |
|----------|------|-------------|
| **M0** | 프로젝트 셋업 | Git, Docker, 프로젝트 초기화 |
| **M1** | 백엔드 기반 | DB 스키마, Problem/Guest API |
| **M2** | 프론트엔드 기반 | 문제 리스트/상세, Monaco Editor |
| **M3** | Judge0 연동 | Run/Submit API, 코드 실행 |
| **M4** | 기능 통합 | FE-BE 연동, 제출 이력 |
| **M5** | QA/배포 준비 | 테스트, 성능, 보안 점검 |
| **M6** | MVP 출시 | 프로덕션 배포, 모니터링 |

## 작업 선택 가이드

### 1. 현재 마일스톤 확인

`docs/project/MILESTONE.md`의 산출물 체크리스트 확인:
- ✅ 완료
- ⬜ 미완료

### 2. 선행 작업 확인

`docs/project/TASK_BREAKDOWN.md`에서 의존성 확인:
```
M1-BE-013 (Problem 엔티티) → M1-BE-022 (ProblemRepository) 필요
M3-BE-003 (Judge0Client) → M3-BE-002 (WebClient 설정) 필요
```

### 3. 영역별 우선순위

```
INFRA → BE → FE (순차 의존)
QA, SEC, PERF (병렬 가능)
```

## 작업 상태 관리

### 상태 코드
- ⬜ **TODO**: 미시작
- 🔄 **IN_PROGRESS**: 진행 중
- ✅ **DONE**: 완료
- ⚠️ **BLOCKED**: 선행 작업 대기

### 진행 체크리스트

작업 시작시:
1. [ ] 선행 작업 완료 확인
2. [ ] 관련 문서 읽기
3. [ ] 작업 코드 확인 (e.g., M2-FE-032)

작업 완료시:
1. [ ] 코드 린트/타입체크 통과
2. [ ] 관련 테스트 작성/통과
3. [ ] 문서 산출물 체크리스트 업데이트

## 크기 추정

| 크기 | 포인트 | 예시 |
|------|--------|------|
| XS | 1 | 설정 변경, 패키지 설치 |
| S | 2 | 단일 컴포넌트/API |
| M | 3 | 여러 파일, 통합 작업 |
| L | 5 | 기능 단위 구현 |
| XL | 8 | 대규모 아키텍처 작업 |

## 관련 스킬

| 스킬 | 용도 |
|------|------|
| `ct-frontend` | 프론트엔드 구현 (M2, M4) |
| `nextjs-developer` | Next.js 패턴 |
| `spring-boot-engineer` | 백엔드 구현 (M1, M3) |
| `devops-engineer` | 인프라/배포 (M0, M5, M6) |
| `test-master` | 테스트 작성 (M5) |

## 관련 문서

| 문서 | 경로 | 내용 |
|------|------|------|
| **마일스톤** | `docs/project/MILESTONE.md` | 전체 로드맵, 완료 조건 |
| **WBS** | `docs/project/TASK_BREAKDOWN.md` | 상세 작업 목록, 의존성 |
| PRD | `docs/PRD.md` | MVP 범위, 성공 지표 |
| API 명세 | `docs/api/API_SPECIFICATION.md` | 엔드포인트 정의 |
| ERD | `docs/database/ERD.md` | 데이터 모델 |
| 아키텍처 | `docs/architecture/SYSTEM_ARCHITECTURE.md` | 시스템 구조 |
| Judge0 연동 | `docs/judge0/INTEGRATION_GUIDE.md` | 코드 실행 연동 |

## 빠른 조회

### 다음 작업 찾기
```
1. MILESTONE.md → 현재 마일스톤의 미완료(⬜) 항목 확인
2. TASK_BREAKDOWN.md → 해당 항목의 작업 코드 찾기
3. 선행 작업 완료 여부 확인
4. 의존성 없는 작업부터 시작
```

### 마일스톤 완료 조건 확인
```
MILESTONE.md → 해당 마일스톤 섹션 → "완료 조건" 체크리스트
```

## MUST DO

- 작업 시작 전 선행 작업 확인
- 작업 코드로 커밋 메시지 prefix (e.g., `[M2-FE-032] Monaco Editor 설치`)
- **작업 완료시 반드시 마크다운 파일 체크 표시 업데이트:**
  ```
  1. docs/project/MILESTONE.md → 산출물 테이블의 상태를 ⬜ → ✅ 로 변경
  2. docs/project/MILESTONE.md → 완료 조건 체크리스트 [ ] → [x] 로 변경
  3. docs/project/TASK_BREAKDOWN.md → 해당 작업 행에 완료 표시 추가 (필요시)
  ```
- 체크 표시 없이는 작업 완료로 간주하지 않음

## MUST NOT DO

- 선행 작업 미완료 상태에서 의존 작업 시작
- 마일스톤 건너뛰기 (M0 → M2 등)
- **문서 체크 표시 업데이트 없이 작업 완료 처리 (절대 금지)**
