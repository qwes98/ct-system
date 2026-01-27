# Task Code Reference

주요 작업 코드 빠른 참조. 전체 목록은 `docs/project/TASK_BREAKDOWN.md` 참조.

## M0: 프로젝트 셋업

### INFRA
| 코드 | 작업 | 선행 |
|------|------|------|
| M0-INFRA-001 | Git 저장소 생성 | - |
| M0-INFRA-002 | 브랜치 보호 규칙 | 001 |
| M0-INFRA-003 | PR/Issue 템플릿 | 001 |
| M0-INFRA-004 | docker-compose.yml | - |
| M0-INFRA-005 | Judge0 로컬 테스트 | 004 |
| M0-INFRA-006 | GitHub Actions | 001 |

### BE (Backend)
| 코드 | 작업 | 선행 |
|------|------|------|
| M0-BE-001 | Spring Boot 프로젝트 | INFRA-001 |
| M0-BE-002 | Gradle 빌드 설정 | 001 |
| M0-BE-003 | 패키지 구조 | 001 |
| M0-BE-004 | application.yml | 001 |
| M0-BE-005 | Checkstyle/Spotless | 001 |
| M0-BE-006 | JaCoCo 설정 | 001 |

### FE (Frontend)
| 코드 | 작업 | 선행 |
|------|------|------|
| M0-FE-001 | Next.js 프로젝트 | INFRA-001 |
| M0-FE-002 | TypeScript 설정 | 001 |
| M0-FE-003 | ESLint/Prettier | 001 |
| M0-FE-004 | Tailwind CSS | 001 |
| M0-FE-005 | shadcn/ui | 001, 004 |
| M0-FE-006 | 폴더 구조 | 001 |

---

## M1: 백엔드 기반

### DB 마이그레이션 (M1-BE-001~008)
```
001 Flyway → 002 categories → 003 problems → 004 test_cases
         → 005 templates → 006 guest_sessions → 007 submissions
         → 008 seed data
```

### 엔티티 (M1-BE-011~017)
```
011 BaseTimeEntity → 012 Category → 013 Problem → 014 TestCase
                                  → 015 Template
                  → 016 GuestSession → 017 Submission
```

### Repository (M1-BE-021~026)
엔티티 1:1 대응

### Service/API (M1-BE-031~038)
```
031 ApiResponse → 032 ExceptionHandler → 033 ProblemService → 034 ProblemController → 035 테스트
                                       → 036 GuestSessionService → 037 GuestController → 038 테스트
```

---

## M2: 프론트엔드 기반

### 공통 컴포넌트 (M2-FE-001~007)
```
001 Layout → 002 Header, 003 Footer
004-007: Button, Card, Badge, Skeleton
```

### API 클라이언트 (M2-FE-011~017)
```
011 Axios → 012 에러 인터셉터 → 013 Problem API → 016 useProblemList
                              → 014 Guest API   → 017 useProblem
015 React Query
```

### 문제 리스트 (M2-FE-021~026)
```
021 ProblemCard → 022 ProblemList → 024 문제 리스트 페이지
023 DifficultyBadge, 025 Pagination
```

### 문제 상세 (M2-FE-031~038)
```
031 Monaco Editor → 032 CodeEditor → 036 레이아웃 → 037 문제 상세 페이지
033 LanguageSelect, 034 ProblemDescription, 035 Examples
```

---

## M3: Judge0 연동

### INFRA (M3-INFRA-001~005)
Judge0 Docker 설정, 네트워크 격리, 리소스 제한

### Judge0 클라이언트 (M3-BE-001~009)
```
001 Config → 002 WebClient → 003 Judge0Client
004 DTO, 005-008 언어별 래퍼 (Python/Java/C++/JS)
```

### Run API (M3-BE-011~016)
```
011 RunRequest → 013 ExecutionService → 014 RunService → 015 Controller
012 RunResponse
```

### Submit API (M3-BE-021~028)
```
021 BlockingQueue → 024 SubmitService → 025 Controller → 027 상태 조회
022-023 DTO, 026 Worker
```

---

## M4: 기능 통합

### FE 실행 기능 (M4-FE-001~007)
```
001 Run API → 003 useRun → 006 RunButton
002 Submit API → 004 useSubmit, 005 useSubmissionPolling → 007 SubmitButton
```

### 결과 표시 (M4-FE-011~016)
```
011 TestResult → 012 RunResult, 013 SubmitResult
014 StatusBadge, 015 상태 폴링 UI, 016 에러 UI
```

### 제출 이력 (M4-FE-021~025)
```
021 Submission API → 022 useSubmissionHistory → 024 SubmissionList → 025 제출 이력 페이지
023 SubmissionCard
```

---

## M5~M6

상세 내용은 `docs/project/TASK_BREAKDOWN.md` 섹션 7~8 참조.

### M5 주요 영역
- **QA**: 버그 수정, 테스트 보완
- **PERF**: 부하 테스트, 성능 최적화
- **SEC**: 취약점 스캔, OWASP 점검
- **INFRA**: 배포 환경 구성

### M6 주요 영역
- **DEPLOY**: 프로덕션 배포
- **OPS**: 모니터링, 알림, 롤백 절차
