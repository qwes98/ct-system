# Tech Stack Decision

기술 스택 선택의 근거와 대안 비교를 문서화합니다.

## 1. Frontend

### 선택: Next.js 14+ (App Router)

| 평가 기준 | Next.js | Create React App | Vite + React |
|-----------|---------|------------------|--------------|
| SSR/SSG 지원 | ✅ 내장 | ❌ | ❌ |
| 라우팅 | ✅ 파일 기반 | ❌ 별도 설정 | ❌ 별도 설정 |
| SEO | ✅ 우수 | ⚠️ 제한적 | ⚠️ 제한적 |
| DX (개발 경험) | ✅ 우수 | ✅ 우수 | ✅ 우수 |
| 배포 용이성 | ✅ Vercel 최적화 | ✅ | ✅ |
| 생태계 | ✅ 풍부 | ✅ 풍부 | ✅ 성장 중 |

**선택 이유:**
1. **SEO 필요성**: 문제 리스트 페이지는 검색 엔진 노출이 필요할 수 있음
2. **API Routes**: 간단한 BFF(Backend for Frontend) 패턴 적용 가능
3. **파일 기반 라우팅**: 빠른 개발 속도
4. **Vercel 배포**: MVP 단계에서 인프라 관리 최소화

**리스크:**
- App Router 학습 곡선 (Pages Router 대비)
- 서버 컴포넌트 개념 이해 필요

---

### 선택: shadcn/ui

| 평가 기준 | shadcn/ui | MUI | Ant Design | Chakra UI |
|-----------|-----------|-----|------------|-----------|
| 번들 크기 | ✅ 최소 (필요한 것만) | ❌ 큼 | ❌ 큼 | ⚠️ 중간 |
| 커스터마이징 | ✅ 완전한 소유권 | ⚠️ 테마 제한 | ⚠️ 테마 제한 | ✅ 좋음 |
| Tailwind 호환 | ✅ 네이티브 | ❌ | ❌ | ⚠️ 부분적 |
| 디자인 품질 | ✅ 모던 | ✅ Material | ✅ Enterprise | ✅ 깔끔 |
| 접근성 | ✅ Radix 기반 | ✅ | ✅ | ✅ |

**선택 이유:**
1. **코드 소유권**: 복사-붙여넣기 방식으로 완전한 커스터마이징 가능
2. **번들 최적화**: 사용하는 컴포넌트만 포함
3. **Tailwind CSS**: 빠른 스타일링, 일관된 디자인 시스템
4. **Radix UI 기반**: 접근성 보장

**리스크:**
- 컴포넌트 직접 관리 필요 (업데이트 수동)

---

### 선택: Monaco Editor

| 평가 기준 | Monaco | CodeMirror 6 | Ace Editor |
|-----------|--------|--------------|------------|
| VS Code 호환 | ✅ 동일 엔진 | ❌ | ❌ |
| 언어 지원 | ✅ 풍부 | ✅ 플러그인 | ✅ |
| 자동완성 | ✅ IntelliSense | ⚠️ 기본적 | ⚠️ 기본적 |
| 번들 크기 | ❌ 큼 (~2MB) | ✅ 작음 | ✅ 작음 |
| 사용자 친숙도 | ✅ VS Code 경험 | ⚠️ | ⚠️ |

**선택 이유:**
1. **VS Code 경험**: 대부분의 개발자가 익숙한 UX
2. **언어 지원**: Python, Java, C++, JavaScript 모두 내장 지원
3. **IntelliSense**: 기본적인 자동완성 제공

**리스크:**
- 번들 크기 (~2MB) → Dynamic import로 완화
- 모바일 지원 제한적 (MVP에서는 데스크톱 우선)

---

## 2. Backend

### 선택: Spring Boot 3.x (Java 17+)

| 평가 기준 | Spring Boot | Node.js (Express/Nest) | Go (Gin/Echo) | Python (FastAPI) |
|-----------|-------------|------------------------|---------------|------------------|
| 타입 안정성 | ✅ 강타입 | ⚠️ TS 필요 | ✅ 강타입 | ⚠️ 힌트 기반 |
| 생태계 | ✅ 방대함 | ✅ 방대함 | ⚠️ 성장 중 | ✅ 좋음 |
| ORM | ✅ JPA/Hibernate | ✅ Prisma/TypeORM | ⚠️ GORM | ✅ SQLAlchemy |
| 동시성 처리 | ✅ Virtual Threads | ✅ Event Loop | ✅ Goroutine | ⚠️ asyncio |
| 채용 시장 | ✅ 한국 시장 우세 | ✅ | ⚠️ | ✅ |
| 엔터프라이즈 적합성 | ✅ 검증됨 | ⚠️ 프로젝트마다 다름 | ⚠️ | ⚠️ |

**선택 이유:**
1. **안정성**: 오랜 기간 검증된 프레임워크
2. **JPA**: 복잡한 쿼리도 타입 안전하게 처리
3. **Virtual Threads (Java 21)**: 높은 동시성 처리 가능
4. **한국 시장**: 백엔드 인력 풀이 풍부
5. **확장 경험**: 향후 교육 플랫폼 확장 시 엔터프라이즈 기능 활용

**리스크:**
- Node.js 대비 초기 설정 복잡
- 메모리 사용량 상대적으로 높음

**대안 검토 - Node.js (NestJS):**
- 풀스택 JavaScript로 팀 구성 단순화 가능
- 하지만 타입 안정성과 엔터프라이즈 확장성에서 Spring이 우위

---

### 선택: PostgreSQL 15+

| 평가 기준 | PostgreSQL | MySQL | MongoDB |
|-----------|------------|-------|---------|
| ACID 준수 | ✅ 완전 | ✅ 완전 | ⚠️ 설정 필요 |
| JSON 지원 | ✅ JSONB | ⚠️ 기본 JSON | ✅ 네이티브 |
| 성능 | ✅ 복잡 쿼리 강점 | ✅ 읽기 강점 | ✅ 쓰기 강점 |
| 확장성 | ✅ | ✅ | ✅ |
| 생태계 | ✅ | ✅ | ✅ |

**선택 이유:**
1. **JSONB**: 테스트케이스 등 반정형 데이터 효율적 저장
2. **복잡 쿼리 성능**: 제출 통계, 리포팅에 유리
3. **오픈소스**: 라이선스 비용 없음
4. **AWS RDS 지원**: 관리형 서비스 쉽게 사용

---

### 선택: Redis 7+

| 평가 기준 | Redis | RabbitMQ | Apache Kafka |
|-----------|-------|----------|--------------|
| 설정 복잡도 | ✅ 단순 | ⚠️ 중간 | ❌ 복잡 |
| 메시지 큐 | ✅ List/Stream | ✅ 전문 MQ | ✅ 대용량 |
| 캐시 기능 | ✅ 본업 | ❌ | ❌ |
| 지연시간 | ✅ 초저지연 | ✅ 낮음 | ⚠️ 배치 최적화 |
| MVP 적합성 | ✅ | ⚠️ 오버스펙 | ❌ 오버스펙 |

**선택 이유:**
1. **다목적**: 캐시 + 메시지 큐 + 세션 저장소를 하나로
2. **단순성**: 운영 부담 최소화
3. **Submit 큐**: Redis List로 간단한 작업 큐 구현
4. **Spring 통합**: Spring Data Redis로 쉬운 연동

**한계:**
- 메시지 영속성 보장이 RabbitMQ 대비 약함
- MVP 규모에서는 문제없음, 확장 시 재검토

---

## 3. Execution Engine

### 선택: Judge0 (Self-hosted)

| 평가 기준 | Judge0 | 자체 구현 | Sphere Engine | HackerRank API |
|-----------|--------|-----------|---------------|----------------|
| 구현 비용 | ✅ 즉시 사용 | ❌ 높음 | ✅ | ✅ |
| 커스터마이징 | ✅ 오픈소스 | ✅ 완전 | ❌ 제한적 | ❌ 제한적 |
| 보안 격리 | ✅ isolate 기반 | ⚠️ 직접 구현 | ✅ | ✅ |
| 비용 | ✅ 무료 | ✅ 인프라만 | ❌ 유료 | ❌ 유료 |
| 언어 지원 | ✅ 60+ 언어 | ⚠️ 직접 추가 | ✅ | ✅ |

**선택 이유:**
1. **빠른 MVP**: 검증된 실행 엔진 즉시 사용
2. **오픈소스**: 필요시 커스터마이징 가능
3. **isolate 기반**: 리눅스 컨테이너 수준 격리 제공
4. **4개 언어 지원**: Python, Java, C++, JavaScript 모두 지원

**리스크:**
- Self-hosted 운영 부담
- 고도화된 보안 필요시 추가 작업 필요 (gVisor 등)

---

## 4. 결정 요약

| 계층 | 선택 | 핵심 이유 |
|------|------|-----------|
| Frontend Framework | Next.js 14+ | SSR, 파일 라우팅, Vercel 배포 |
| UI Library | shadcn/ui | 번들 최적화, 커스터마이징 |
| Code Editor | Monaco | VS Code UX, 언어 지원 |
| Backend Framework | Spring Boot 3.x | 안정성, JPA, 확장성 |
| Database | PostgreSQL 15+ | JSONB, 복잡 쿼리, 오픈소스 |
| Message Queue/Cache | Redis 7+ | 다목적, 단순성 |
| Execution Engine | Judge0 | 빠른 MVP, 오픈소스 |

---

## 5. 향후 재검토 시점

| 기술 | 재검토 트리거 | 대안 |
|------|---------------|------|
| Next.js | 복잡한 상태 관리 필요시 | React + Vite + React Router |
| Spring Boot | 마이크로서비스 분리시 | Go/Node.js for specific services |
| PostgreSQL | 초대용량 쓰기 부하시 | Sharding 또는 NoSQL 부분 도입 |
| Redis | 메시지 보장 필요시 | RabbitMQ 또는 Kafka |
| Judge0 | 채용 플랫폼 확장시 | gVisor/Firecracker 기반 자체 구현 |
