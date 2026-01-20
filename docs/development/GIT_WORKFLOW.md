# Git Workflow

프로젝트의 Git 브랜치 전략 및 협업 워크플로우를 정의합니다.

## 1. 브랜치 전략

### 1.1 메인 브랜치

```
main (production)
  │
  ├── develop (integration)
  │     │
  │     ├── feature/xxx
  │     ├── fix/xxx
  │     └── refactor/xxx
  │
  └── release/x.x.x (staging)
        │
        └── hotfix/xxx
```

| 브랜치 | 용도 | 보호 | 배포 환경 |
|--------|------|------|-----------|
| `main` | 프로덕션 코드 | Protected | Production |
| `develop` | 개발 통합 | Protected | Development |
| `release/*` | 릴리즈 준비 | Protected | Staging |
| `feature/*` | 새 기능 개발 | - | PR Preview |
| `fix/*` | 버그 수정 | - | - |
| `hotfix/*` | 긴급 수정 | - | - |

### 1.2 브랜치 네이밍 규칙

```
<type>/<issue-number>-<short-description>
```

**Type:**
| Type | 설명 | 예시 |
|------|------|------|
| feature | 새로운 기능 | `feature/42-add-submission-api` |
| fix | 버그 수정 | `fix/56-polling-timeout` |
| hotfix | 긴급 수정 | `hotfix/99-critical-security-fix` |
| refactor | 리팩토링 | `refactor/78-improve-judge0-client` |
| docs | 문서 작업 | `docs/23-update-api-docs` |
| test | 테스트 추가 | `test/45-add-submission-tests` |
| chore | 설정/빌드 | `chore/12-update-dependencies` |

---

## 2. 개발 워크플로우

### 2.1 기능 개발 플로우

```
1. Issue 생성/할당
        │
        ▼
2. develop에서 feature 브랜치 생성
   git checkout develop
   git pull origin develop
   git checkout -b feature/42-add-submission-api
        │
        ▼
3. 개발 및 커밋
   git add .
   git commit -m "feat(submission): add submission API"
        │
        ▼
4. Push 및 PR 생성
   git push origin feature/42-add-submission-api
        │
        ▼
5. 코드 리뷰
        │
        ▼
6. develop에 머지 (Squash and merge)
        │
        ▼
7. 브랜치 삭제
```

### 2.2 릴리즈 플로우

```
1. develop에서 release 브랜치 생성
   git checkout develop
   git checkout -b release/1.0.0
        │
        ▼
2. 버전 번호 업데이트
   - package.json, build.gradle 등
        │
        ▼
3. QA / 버그 수정
   git commit -m "fix(release): fix minor bugs"
        │
        ▼
4. main에 머지
   git checkout main
   git merge release/1.0.0
   git tag v1.0.0
        │
        ▼
5. develop에도 머지
   git checkout develop
   git merge release/1.0.0
        │
        ▼
6. release 브랜치 삭제
```

### 2.3 Hotfix 플로우

```
1. main에서 hotfix 브랜치 생성
   git checkout main
   git checkout -b hotfix/critical-security-fix
        │
        ▼
2. 긴급 수정 및 커밋
        │
        ▼
3. main에 머지 및 태그
   git checkout main
   git merge hotfix/critical-security-fix
   git tag v1.0.1
        │
        ▼
4. develop에도 머지
   git checkout develop
   git merge hotfix/critical-security-fix
        │
        ▼
5. hotfix 브랜치 삭제
```

---

## 3. 커밋 컨벤션

### 3.1 커밋 메시지 형식

```
<type>(<scope>): <subject>

<body>

<footer>
```

### 3.2 Type

| Type | 설명 | 예시 |
|------|------|------|
| feat | 새로운 기능 | `feat(problem): add problem list API` |
| fix | 버그 수정 | `fix(submission): fix timeout error` |
| docs | 문서 변경 | `docs(readme): update installation guide` |
| style | 코드 포맷팅 | `style(lint): apply prettier formatting` |
| refactor | 리팩토링 | `refactor(service): extract common logic` |
| test | 테스트 | `test(api): add integration tests` |
| chore | 빌드/설정 | `chore(deps): update dependencies` |
| perf | 성능 개선 | `perf(query): optimize problem list query` |
| ci | CI/CD | `ci(github): add deploy workflow` |

### 3.3 Scope

| Scope | 설명 |
|-------|------|
| problem | 문제 관련 |
| submission | 제출 관련 |
| execution | 실행 관련 |
| auth | 인증 관련 |
| api | API 전반 |
| ui | UI 컴포넌트 |
| editor | 코드 에디터 |
| infra | 인프라 |
| deps | 의존성 |

### 3.4 Subject 규칙

- 영문 소문자로 시작
- 명령문 형태 (동사 원형)
- 마침표 없음
- 50자 이내

**Good:**
```
feat(submission): add polling for submission status
fix(editor): prevent cursor jump on language change
refactor(api): extract error handling to middleware
```

**Bad:**
```
feat(submission): Added polling.        # 과거형, 마침표
Fix: submission error                   # 대문자, scope 누락
update stuff                            # 모호함
```

### 3.5 Body 규칙

- 72자마다 줄바꿈
- **무엇을**, **왜** 변경했는지 설명
- **어떻게**는 코드가 설명

**예시:**
```
feat(submission): add submission status polling

- Add useSubmissionPolling hook for status updates
- Implement exponential backoff for polling interval
- Update SubmissionResult component to use polling

The previous implementation required manual refresh.
This change provides real-time feedback to users.
```

### 3.6 Footer 규칙

**이슈 연결:**
```
Closes #42
Fixes #56
Resolves #78
```

**Breaking Change:**
```
BREAKING CHANGE: change API response format

The response now wraps data in a 'data' field.
Migration: update all API consumers to access response.data
```

---

## 4. Pull Request

### 4.1 PR 제목 형식

```
<type>(<scope>): <description>
```

커밋 메시지 제목과 동일한 형식 사용.

**예시:**
- `feat(submission): add submission API with polling`
- `fix(editor): resolve cursor position issue`

### 4.2 PR 템플릿

```markdown
## Summary
<!-- 변경 사항 요약 -->

## Changes
<!-- 주요 변경 내용 목록 -->
-
-

## Test Plan
<!-- 테스트 방법 -->
- [ ] Unit tests added/updated
- [ ] Manual testing done
- [ ] E2E tests (if applicable)

## Screenshots (if applicable)
<!-- UI 변경시 스크린샷 -->

## Related Issues
<!-- 관련 이슈 -->
Closes #

## Checklist
- [ ] Code follows project conventions
- [ ] Tests pass locally
- [ ] Documentation updated (if needed)
- [ ] No console.log or debug code
```

### 4.3 PR 머지 전략

| 상황 | 머지 방식 | 이유 |
|------|-----------|------|
| feature → develop | Squash and merge | 깔끔한 히스토리 |
| release → main | Merge commit | 릴리즈 포인트 보존 |
| hotfix → main/develop | Merge commit | 히스토리 추적 |
| develop → release | Merge commit | 통합 포인트 보존 |

### 4.4 리뷰 가이드라인

**리뷰어 역할:**
- 코드 품질 확인
- 버그/보안 이슈 탐지
- 설계/아키텍처 피드백
- 테스트 충분성 확인

**리뷰 코멘트 종류:**
```
# 차단 (반드시 수정)
🚨 [BLOCKER] 보안 취약점이 있습니다...

# 필수 (수정 권장)
⚠️ [MUST] 이 경우 NPE가 발생할 수 있습니다...

# 제안 (선택적)
💡 [SUGGESTION] 이 부분은 이렇게 하면 더 좋을 것 같습니다...

# 질문
❓ [QUESTION] 이 로직의 의도가 무엇인가요?

# 칭찬
👍 [NICE] 깔끔한 처리입니다!
```

---

## 5. 버전 관리

### 5.1 Semantic Versioning

```
MAJOR.MINOR.PATCH

예: 1.2.3
```

| 변경 | 버전 | 예시 |
|------|------|------|
| 하위 호환 안 됨 | MAJOR++ | 1.0.0 → 2.0.0 |
| 새 기능 추가 | MINOR++ | 1.0.0 → 1.1.0 |
| 버그 수정 | PATCH++ | 1.0.0 → 1.0.1 |

### 5.2 태그 규칙

```bash
# 태그 생성
git tag -a v1.0.0 -m "Release version 1.0.0"

# 태그 푸시
git push origin v1.0.0

# 모든 태그 푸시
git push origin --tags
```

### 5.3 Changelog

```markdown
# Changelog

## [1.1.0] - 2024-01-20

### Added
- Submission status polling (#42)
- Problem category filter (#45)

### Changed
- Improve editor performance (#48)

### Fixed
- Fix timeout error on large submissions (#56)

## [1.0.0] - 2024-01-15

### Added
- Initial release
- Problem list and detail pages
- Code editor with Monaco
- Run and Submit functionality
```

---

## 6. 브랜치 보호 규칙

### 6.1 main 브랜치

```yaml
# GitHub Branch Protection Rules
- Require pull request reviews: 1
- Require status checks to pass:
  - build
  - test
  - lint
- Require branches to be up to date
- Include administrators: Yes
- Allow force pushes: No
- Allow deletions: No
```

### 6.2 develop 브랜치

```yaml
- Require pull request reviews: 1
- Require status checks to pass:
  - build
  - test
- Include administrators: Yes
- Allow force pushes: No
- Allow deletions: No
```

---

## 7. Git Hooks

### 7.1 pre-commit

```bash
#!/bin/sh
# .husky/pre-commit

# Frontend
cd frontend
npm run lint
npm run type-check

# Backend
cd ../backend
./gradlew spotlessCheck
```

### 7.2 commit-msg

```bash
#!/bin/sh
# .husky/commit-msg

# 커밋 메시지 형식 검사
npx commitlint --edit $1
```

### 7.3 commitlint 설정

```javascript
// commitlint.config.js
module.exports = {
  extends: ['@commitlint/config-conventional'],
  rules: {
    'type-enum': [
      2,
      'always',
      ['feat', 'fix', 'docs', 'style', 'refactor', 'test', 'chore', 'perf', 'ci']
    ],
    'scope-case': [2, 'always', 'lower-case'],
    'subject-case': [2, 'always', 'lower-case'],
    'subject-empty': [2, 'never'],
    'subject-full-stop': [2, 'never', '.'],
    'header-max-length': [2, 'always', 72]
  }
};
```

---

## 8. 자주 사용하는 Git 명령어

### 8.1 기본 작업

```bash
# 최신 develop 가져오기
git checkout develop
git pull origin develop

# 새 브랜치 생성
git checkout -b feature/42-new-feature

# 변경사항 스테이징
git add .
git add -p  # 대화형 스테이징

# 커밋
git commit -m "feat(scope): message"

# 푸시
git push origin feature/42-new-feature
```

### 8.2 브랜치 관리

```bash
# 브랜치 목록
git branch -a

# 브랜치 삭제 (로컬)
git branch -d feature/42-new-feature

# 브랜치 삭제 (원격)
git push origin --delete feature/42-new-feature

# 원격 브랜치 정리
git fetch --prune
```

### 8.3 리베이스

```bash
# develop 기반으로 리베이스
git checkout feature/42-new-feature
git rebase develop

# 충돌 해결 후
git add .
git rebase --continue

# 리베이스 취소
git rebase --abort
```

### 8.4 되돌리기

```bash
# 마지막 커밋 수정
git commit --amend

# 커밋 되돌리기 (새 커밋 생성)
git revert HEAD

# 스테이징 취소
git reset HEAD file.txt

# 변경사항 버리기
git checkout -- file.txt
```

---

## 9. 트러블슈팅

### 9.1 충돌 해결

```bash
# 1. 충돌 발생 시
git status  # 충돌 파일 확인

# 2. 파일 수동 편집
# <<<<<<< HEAD
# 현재 브랜치 내용
# =======
# 머지하려는 브랜치 내용
# >>>>>>> branch-name

# 3. 해결 후
git add <resolved-files>
git commit -m "resolve merge conflicts"
```

### 9.2 실수 복구

```bash
# 잘못된 브랜치에 커밋한 경우
git checkout correct-branch
git cherry-pick <commit-hash>
git checkout wrong-branch
git reset --hard HEAD~1

# 푸시 전 커밋 취소
git reset --soft HEAD~1

# 푸시 후 커밋 되돌리기
git revert <commit-hash>
git push
```
