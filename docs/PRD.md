## PRD

### 1) 목표와 배경

* **제품 목표:** 코딩테스트를 공부하는 학습자를 위한 웹 기반 코딩테스트 연습 플랫폼(MVP)
* **확장 방향:** 교육용 기능(커리큘럼/학습 진도/피드백/해설/클래스 등)로 확장 가능한 구조
* **비용 목표:** 월 1만원 이하 (~$7-8 USD) - 무료/저가 인프라 구성으로 최소 비용 운영

### 2) 타깃 유저 (A.1)

* 코딩테스트를 공부하는 개인 학습자(교육용)
* 초기에 기업/채용 평가 목적은 제외

### 3) MVP 성공 지표 (A.2)

* **제출 완료율:** 90%+
* **Submit 결과 반환:** 10초 내 95% (P95)
* **API 가용성:** 95%+ (MVP 단계 완화된 목표)

---

## 4) 범위 (MVP)

### 포함

* 문제 리스트/상세(설명, 제약, 예시)
* 코드 에디터 + 언어 선택(Python/Java/C++/JavaScript)
* **Run:** 샘플 테스트만 실행
* **Submit:** 전체 테스트(샘플+숨김) 채점 + 제출 기록 저장
* 제출 상태 표시: **queued / running / done**
* 게스트 사용자 제출 이력 조회(디바이스 기준)

### 제외

* 리더보드/랭킹/대회
* 부분점수/스코어링(B.5)
* 부정행위/유사도 검사(D.11)
* 상세 에러 로그 노출(E.13) (단, “에러 여부”만 표시)

---

## 5) 문제/채점 정책

### 5.1 문제 형태 (B.3)

* 모든 문제는 **함수 형태로만 출제**하도록 가이드

  * 예: `solve(input) -> output` 또는 언어별 표준 함수 시그니처 제공
* 플랫폼은 언어별 **템플릿 코드(함수 시그니처 + I/O 래핑)**를 제공

### 5.2 테스트 공개 정책 (B.4)

* **샘플 테스트:** 공개(유저가 Run에서 확인)
* **숨김 테스트:** 비공개(Submit에서만 사용)

### 5.3 결과/로그 노출 정책 (E.13)

* 결과는 아래만 노출:

  * 샘플/전체 각각에 대해 **성공/실패 여부**
  * “에러가 있다/없다” (컴파일/런타임/타임아웃 포함)
* **stderr/컴파일 로그/실패 케이스 입력·기대출력 등 상세 정보는 비공개**

---

## 6) 기술 아키텍처 (저비용 MVP 구성)

### 6.1 전체 구성

```
Vercel (Next.js Frontend) → Single VM (Spring Boot + Judge0)
                                    ↓
                              SQLite (File DB)
```

* **Frontend:** Vercel Free Tier 호스팅
* **Backend:** 단일 VM에서 Spring Boot + Judge0 운영
* **Database:** SQLite (MVP) → PostgreSQL (확장시)
* **Queue:** In-Memory BlockingQueue (MVP) → Redis (확장시)

### 6.2 인프라 옵션

| 구성요소 | Option A (무료) | Option B (저가) |
|----------|-----------------|-----------------|
| Frontend | Vercel Free | Vercel Free |
| Backend Server | Oracle Cloud Free Tier | VPS ~$5-6/월 |
| Database | SQLite | SQLite |
| **월 총 비용** | **₩0** | **~₩7,000** |

### 6.3 Frontend

* Framework: Next.js (Vercel Free Tier 호스팅)
* UI: **shadcn/ui**
* Editor: Monaco (함수형 템플릿/언어별 하이라이팅)

### 6.4 Backend (Spring) — 핵심 책임

* 문제/테스트케이스/템플릿 제공 API
* Run/Submit 요청 수신
* 제출 상태 머신 관리(queued/running/done)
* Judge0 호출 및 결과 수집
* 제출 이력 저장/조회(게스트 기준)

### 6.5 Queue/Worker (저비용 구성)

* **In-Memory BlockingQueue**로 Submit 비동기 처리
* 목표 동시성 (MVP - 축소된 목표):

  * Run: 동시 **10**
  * Submit: 동시 **5**

> Note: 유저가 거의 없는 MVP 단계에서는 낮은 동시성으로 충분. 확장시 Redis 도입

---

## 7) 보안/샌드박싱 요구사항 (C.8: 교육용 기준으로 정의)

교육용이지만 **불특정 다수가 코드를 실행**하므로 “기본 격리”는 필수. 다만 채용급(강화 격리)까지는 MVP에서 제외.

### 필수(MVP)

* 실행 환경은 **컨테이너 기반 격리**(Judge0 기본)
* **네트워크 차단**(Outbound/Inbound 모두)
* 리소스 제한:

  * CPU limit: 1 vCPU
  * Memory limit: **256MB** (저사양 VM 최적화)
  * Time limit: 5초 (문제별 설정 가능)
* 실행 후 **컨테이너/임시 파일 정리**
* 시스템 보호:

  * 요청 rate limit(IP 기준)
  * 제출 크기 제한(소스 코드 길이, 입력 크기)

### 제외(로드맵)

* gVisor/Firecracker 같은 강화 격리
* 커널 exploit 대응 수준의 하드닝
* 고가용성 (MVP는 단일 서버 운영)
* 자동 스케일링

---

## 8) 인증/계정 정책 (D.9~D.10)

* **MVP: 게스트만**
* 게스트 식별:

  * 브라우저 local token(세션/디바이스 ID) 발급
* 제출 이력 조회:

  * 동일 디바이스/토큰 기준으로 제출 목록 제공

---

## 9) UX 정책 (E.12)

* Run: 샘플만 실행(즉시 피드백)
* Submit: 전체 테스트 + 기록 저장
* 상태 표시:

  * queued → running → done
* 결과 표시:

  * 샘플/전체 통과 여부 + 에러 유무만
