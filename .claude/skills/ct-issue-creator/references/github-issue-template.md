# GitHub Issue Templates

## 기본 템플릿

```markdown
## 개요

{ClickUp 태스크 내용을 요약. 왜 이 작업이 필요한지 컨텍스트 제공}

**ClickUp 태스크**: {task_url}

## 목표

- {명확하고 측정 가능한 목표 1}
- {명확하고 측정 가능한 목표 2}

## 설계

### 기술적 접근

{구현 방법 상세 설명}

### 파일 변경 범위

| 파일 | 변경 내용 | 신규/수정 |
|------|----------|----------|
| `path/to/file1` | {변경 내용} | 수정 |
| `path/to/file2` | {변경 내용} | 신규 |

### 의존성

**선행 작업**:
- [ ] #{issue_number} - {의존하는 이슈}

**외부 의존성**:
- {라이브러리, API 등}

## 구현 체크리스트

- [ ] {구현 항목 1}
- [ ] {구현 항목 2}
- [ ] 코드 린트/타입체크 통과
- [ ] 테스트 작성 및 통과

## 엣지 케이스

- {예외 상황 1과 처리 방법}
- {예외 상황 2와 처리 방법}

## 테스트 전략

- **단위 테스트**: {대상 함수/메서드}
- **통합 테스트**: {검증할 시나리오}

## 참고 문서

- [PRD](docs/PRD.md)
- {관련 문서 링크}
```

## Frontend 확장 템플릿

Frontend 도메인 작업에 추가할 섹션:

```markdown
## 컴포넌트 설계

### 컴포넌트 트리
```
ParentComponent
├── ChildComponent1
│   └── GrandchildComponent
└── ChildComponent2
```

### Props/State 정의
```typescript
interface ComponentProps {
  // props 정의
}

interface ComponentState {
  // 상태 정의
}
```

## UI/UX 고려사항

- **반응형**: {모바일/데스크톱 대응}
- **접근성**: {WCAG 준수 항목}
- **로딩 상태**: {스켈레톤/스피너}
- **에러 상태**: {에러 UI 표시}
```

## Backend 확장 템플릿

Backend 도메인 작업에 추가할 섹션:

```markdown
## API 설계

### 엔드포인트
```
[METHOD] /api/v1/path
```

### Request
```json
{
  "field": "value"
}
```

### Response (성공)
```json
{
  "success": true,
  "data": {},
  "timestamp": "2025-01-01T00:00:00Z"
}
```

### Response (에러)
```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "에러 메시지"
  },
  "timestamp": "2025-01-01T00:00:00Z"
}
```

## 레이어별 구현

### Controller
- 요청 검증
- 응답 변환

### Service
- 비즈니스 로직
- 트랜잭션 관리

### Repository
- 데이터 접근
- 쿼리 최적화
```

## gh cli 명령어 예시

### 기본 Issue 생성

```bash
gh issue create \
  --title "[M2-FE] 문제 목록 페이지 구현" \
  --label "frontend,enhancement" \
  --body "$(cat <<'EOF'
## 개요
...
EOF
)"
```

### 라벨과 함께 생성

```bash
gh issue create \
  --title "[M1-BE] Problem API 구현" \
  --label "backend,api,enhancement" \
  --assignee "@me" \
  --body "$(cat <<'EOF'
...
EOF
)"
```

### Milestone 지정

```bash
gh issue create \
  --title "[M3-BE] Judge0 연동" \
  --milestone "M3-Judge0" \
  --body "$(cat <<'EOF'
...
EOF
)"
```

## 라벨 가이드

| 라벨 | 용도 |
|------|------|
| `frontend` | UI/클라이언트 관련 |
| `backend` | 서버/API 관련 |
| `infra` | 인프라/배포 관련 |
| `enhancement` | 새 기능 |
| `bug` | 버그 수정 |
| `documentation` | 문서 작업 |
| `priority:high` | 높은 우선순위 |
| `priority:medium` | 중간 우선순위 |
| `priority:low` | 낮은 우선순위 |

## Issue 제목 컨벤션

```
[{마일스톤}-{도메인}] {간결한 설명}

예시:
[M1-BE] Problem 엔티티 및 Repository 구현
[M2-FE] Monaco Editor 통합
[M3-BE] Judge0 Client 구현
[M4-INT] Frontend-Backend 제출 연동
[M5-QA] E2E 테스트 작성
```
