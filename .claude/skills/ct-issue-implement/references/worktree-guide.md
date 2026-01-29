# Git Worktree 사용 가이드

Git worktree는 하나의 저장소에서 여러 브랜치를 동시에 체크아웃할 수 있게 해주는 기능입니다.

## 기본 개념

### Worktree란?

- 하나의 Git 저장소에서 여러 작업 디렉토리를 동시에 유지
- 각 worktree는 독립적인 브랜치를 체크아웃
- 브랜치 전환 없이 여러 작업을 병렬로 진행 가능

### 장점

- **컨텍스트 스위칭 최소화**: stash 없이 다른 브랜치 작업 가능
- **병렬 작업**: 여러 이슈를 동시에 진행
- **빠른 리뷰**: 다른 브랜치 코드를 별도 디렉토리에서 즉시 확인

## 기본 명령어

### Worktree 생성

```bash
# 기존 브랜치로 worktree 생성
git worktree add <path> <branch>

# 새 브랜치를 만들며 worktree 생성
git worktree add -b <new-branch> <path> <start-point>

# 원격 브랜치 추적
git worktree add <path> origin/<branch>
```

### 예시

```bash
# feature/login 브랜치를 ../worktrees/login 에 체크아웃
git worktree add ../worktrees/login feature/login

# 원격 브랜치를 기반으로 생성
git worktree add ../worktrees/bugfix origin/bugfix/123-fix-auth
```

### Worktree 목록 확인

```bash
git worktree list
```

출력 예시:
```
/Users/dev/project         abc1234 [main]
/Users/dev/worktrees/login def5678 [feature/login]
```

### Worktree 제거

```bash
# 일반 제거 (clean 상태일 때)
git worktree remove <path>

# 강제 제거 (변경사항 있을 때)
git worktree remove --force <path>

# 또는 디렉토리 삭제 후 prune
rm -rf <path>
git worktree prune
```

## 권장 디렉토리 구조

```
project/
├── .git/
├── src/
├── ...
└── (main worktree)

worktrees/
├── feature-login/     # feature/login 브랜치
├── bugfix-123/        # bugfix/123 브랜치
└── infra-6-cicd/      # infra/6-cicd 브랜치
```

### 경로 규칙

1. **프로젝트 외부에 생성**: `../worktrees/` 권장
2. **브랜치명 sanitize**: `/`를 `-`로 치환
3. **일관된 네이밍**: 브랜치명 기반으로 자동 생성

## 주의사항

### 동일 브랜치 제한

- 하나의 브랜치는 한 번에 하나의 worktree에서만 체크아웃 가능
- 이미 체크아웃된 브랜치로 worktree 생성 시 에러 발생

```bash
# 에러 예시
fatal: 'feature/login' is already checked out at '/path/to/worktree'
```

**해결책:**
```bash
# 기존 worktree 확인
git worktree list

# 기존 worktree 제거 후 재생성
git worktree remove ../worktrees/feature-login
git worktree add ../worktrees/feature-login feature/login
```

### 공유되는 것들

- `.git` 디렉토리 (모든 worktree가 공유)
- Git hooks
- Git config
- Remote 설정

### 독립적인 것들

- Working directory
- Index (staging area)
- HEAD

## 일반적인 워크플로우

### 1. 새 이슈 작업 시작

```bash
# 원격에서 최신 정보 가져오기
git fetch origin

# 이슈 브랜치로 worktree 생성
git worktree add ../worktrees/issue-123 origin/feature/123-new-feature

# worktree로 이동하여 작업
cd ../worktrees/issue-123
```

### 2. 작업 완료 후 정리

```bash
# 메인 디렉토리로 복귀
cd /path/to/main/project

# worktree 제거
git worktree remove ../worktrees/issue-123

# 필요시 브랜치도 삭제
git branch -d feature/123-new-feature
```

### 3. 긴급 버그 수정 (현재 작업 중단 없이)

```bash
# 현재 작업 중인 상태에서 hotfix worktree 생성
git worktree add ../worktrees/hotfix origin/hotfix/urgent-fix

# hotfix 작업
cd ../worktrees/hotfix
# ... 수정 및 커밋 ...
git push origin hotfix/urgent-fix

# 원래 작업으로 복귀
cd /path/to/original/worktree

# hotfix worktree 정리
git worktree remove ../worktrees/hotfix
```

## 트러블슈팅

### "already locked" 에러

```bash
# lock 해제
git worktree unlock <path>
```

### "not a valid path" 에러

worktree 디렉토리가 삭제되었지만 Git이 인식하지 못할 때:

```bash
# 고아 worktree 정리
git worktree prune
```

### 원격 브랜치를 찾을 수 없을 때

```bash
# fetch 후 재시도
git fetch origin

# 브랜치 존재 확인
git branch -r | grep <branch-name>
```

## IDE 통합

### VS Code

- 각 worktree를 별도 창으로 열기
- 멀티 루트 워크스페이스로 여러 worktree 동시 관리

### IntelliJ

- 각 worktree를 별도 프로젝트로 열기
- 같은 저장소의 다른 인스턴스로 인식

## 참고 자료

- [Git Worktree 공식 문서](https://git-scm.com/docs/git-worktree)
- [Pro Git - Git Worktree](https://git-scm.com/book/en/v2/Git-Tools-Advanced-Merging#_worktrees)
