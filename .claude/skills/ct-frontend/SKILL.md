---
name: ct-frontend
description: 코딩테스트 연습 플랫폼(ct-system) 프론트엔드 개발. Next.js + shadcn/ui + Monaco Editor 기반 문제 풀이 UI 구현시 사용.
triggers:
  - ct-system frontend
  - 문제 목록
  - 문제 풀이
  - 코드 에디터
  - Monaco Editor
  - 제출 결과
  - submission
role: specialist
scope: implementation
output-format: code
---

# CT-System Frontend Development

코딩테스트 연습 플랫폼 MVP 프론트엔드 개발 가이드.

## 프로젝트 개요

- **목적**: 코딩테스트 공부를 위한 웹 기반 연습 플랫폼
- **호스팅**: Vercel Free Tier
- **비용 목표**: 월 1만원 이하 (프론트엔드는 무료)

## 기술 스택

| 항목 | 기술 |
|------|------|
| Framework | Next.js 14+ (App Router) |
| UI Library | shadcn/ui (Radix UI 기반) |
| Code Editor | Monaco Editor |
| State | React Context / Zustand |
| HTTP Client | Fetch API |
| Styling | Tailwind CSS |

## 핵심 페이지

```
app/
├── page.tsx                    # 문제 리스트
├── problems/[id]/page.tsx      # 문제 풀이 (에디터 + 결과)
└── submissions/page.tsx        # 제출 이력
```

## 주요 컴포넌트

### 1. 문제 리스트 (`/`)
- 페이지네이션 (page, size)
- 난이도/카테고리 필터
- 문제 카드 (title, difficulty, acceptanceRate)

### 2. 문제 풀이 페이지 (`/problems/[id]`)

**레이아웃 구성:**
```
┌─────────────────────────────────────────────────────┐
│ Problem Description (left)  │  Code Editor (right)  │
│ - 설명                      │  - Monaco Editor      │
│ - 제약사항                  │  - 언어 선택          │
│ - 예시 입출력               │  - Run / Submit 버튼  │
├─────────────────────────────┴───────────────────────┤
│                    결과 패널                         │
│ - 테스트 결과 (passed/failed)                       │
│ - 실행 시간/메모리                                  │
└─────────────────────────────────────────────────────┘
```

**핵심 기능:**
- **Run**: 샘플 테스트만 실행 (동기, 즉시 결과)
- **Submit**: 전체 테스트 실행 (비동기, 폴링)
- **상태 표시**: `queued` → `running` → `done`

### 3. Monaco Editor 설정

```tsx
// 지원 언어: Python, Java, C++, JavaScript
const LANGUAGE_MAP = {
  PYTHON: 'python',
  JAVA: 'java',
  CPP: 'cpp',
  JAVASCRIPT: 'javascript',
};

// 에디터 옵션
const editorOptions = {
  minimap: { enabled: false },
  fontSize: 14,
  tabSize: 4,
  automaticLayout: true,
};
```

### 4. 제출 상태 폴링

```tsx
// Submit 후 2초 간격 폴링
const pollSubmission = async (submissionId: string) => {
  const poll = async () => {
    const res = await fetch(`/api/v1/submissions/${submissionId}`);
    const data = await res.json();

    if (data.data.status === 'DONE') {
      setResult(data.data);
      return;
    }

    setTimeout(poll, 2000); // 2초 후 재시도
  };
  poll();
};
```

## API 연동

### Base URL
- Local: `http://localhost:8080/api/v1`
- Production: `https://api.ct-system.com/api/v1`

### 핵심 엔드포인트

| 기능 | Method | Endpoint |
|------|--------|----------|
| 문제 목록 | GET | `/problems` |
| 문제 상세 | GET | `/problems/{id}` |
| 템플릿 조회 | GET | `/problems/{id}/template?language=PYTHON` |
| Run (샘플) | POST | `/run` |
| Submit (전체) | POST | `/submit` |
| 제출 상태 | GET | `/submissions/{id}` |
| 제출 이력 | GET | `/submissions` |

### 게스트 토큰

```tsx
// X-Guest-Token 헤더로 전송
// localStorage에 저장하여 제출 이력 추적
const guestToken = localStorage.getItem('guestToken');
headers: { 'X-Guest-Token': guestToken }
```

## 결과 노출 정책

**노출 O:**
- 성공/실패 여부
- 에러 유무 (컴파일/런타임/타임아웃)
- 통과 테스트 수 (e.g., 12/17)

**노출 X:**
- stderr/컴파일 로그
- 실패 케이스의 입력/기대출력
- 숨김 테스트 상세 정보

## 성능 목표

- Submit 결과 반환: 10초 내 (P95)
- 폴링 간격: 2초
- 동시성: Run 10 / Submit 5

## 관련 스킬

| 스킬 | 용도 |
|------|------|
| `nextjs-developer` | Next.js 14+ App Router 패턴 |
| `nextjs-shadcn` | shadcn/ui 컴포넌트 스타일링 |
| `nextjs-server-client-components` | Server/Client 컴포넌트 구분 |
| `react-best-practices` | React 성능 최적화 |
| `typescript-pro` | TypeScript 타입 정의 |

## 관련 문서

| 문서 | 경로 |
|------|------|
| PRD | `docs/PRD.md` |
| API 명세 | `docs/api/API_SPECIFICATION.md` |
| 에러 코드 | `docs/api/ERROR_CODES.md` |
| 코딩 컨벤션 | `docs/development/CODING_CONVENTION.md` |
| 시스템 아키텍처 | `docs/architecture/SYSTEM_ARCHITECTURE.md` |

## MUST DO

- App Router 사용 (NOT Pages Router)
- TypeScript strict mode
- Server Components 기본, 필요시만 'use client'
- `@/` 절대 경로 import
- `cn()` 유틸로 조건부 스타일 병합
- Monaco Editor lazy loading (동적 import)

## MUST NOT DO

- 모든 컴포넌트를 Client Component로 만들기
- 숨김 테스트 정보 노출
- 상세 에러 로그 노출
- 불필요한 외부 상태 관리 라이브러리 추가
