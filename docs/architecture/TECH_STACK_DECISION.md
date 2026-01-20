# Tech Stack Decision

기술 스택 선택의 근거와 대안 비교를 문서화합니다.

## 0. 비용 목표

**MVP 월 운영비 목표: 1만원 이하 (~$7-8 USD)**

이 목표를 달성하기 위해 모든 기술 선택에서 비용을 최우선으로 고려합니다.

---

## 1. Frontend

### 선택: Next.js 14+ (App Router)

| 평가 기준 | Next.js | Create React App | Vite + React |
|-----------|---------|------------------|--------------|
| SSR/SSG 지원 | O 내장 | X | X |
| 라우팅 | O 파일 기반 | X 별도 설정 | X 별도 설정 |
| SEO | O 우수 | - 제한적 | - 제한적 |
| DX (개발 경험) | O 우수 | O 우수 | O 우수 |
| **무료 호스팅** | **O Vercel Free** | - Netlify | - Netlify |
| 생태계 | O 풍부 | O 풍부 | O 성장 중 |

**선택 이유:**
1. **Vercel Free Tier**: 프론트엔드 호스팅 비용 **₩0**
2. **SEO 필요성**: 문제 리스트 페이지는 검색 엔진 노출이 필요할 수 있음
3. **API Routes**: 간단한 BFF(Backend for Frontend) 패턴 적용 가능
4. **파일 기반 라우팅**: 빠른 개발 속도

**Vercel Free Tier 제한:**
- 100GB 대역폭/월
- 빌드 시간 6000분/월
- 상업적 사용 가능

---

### 선택: shadcn/ui

| 평가 기준 | shadcn/ui | MUI | Ant Design | Chakra UI |
|-----------|-----------|-----|------------|-----------|
| 번들 크기 | O 최소 | X 큼 | X 큼 | - 중간 |
| 커스터마이징 | O 완전한 소유권 | - 테마 제한 | - 테마 제한 | O 좋음 |
| Tailwind 호환 | O 네이티브 | X | X | - 부분적 |
| **비용 (라이선스)** | **O 무료** | **O 무료** | **O 무료** | **O 무료** |

**선택 이유:**
1. **코드 소유권**: 복사-붙여넣기 방식으로 완전한 커스터마이징 가능
2. **번들 최적화**: 사용하는 컴포넌트만 포함 → Vercel 대역폭 절약
3. **Tailwind CSS**: 빠른 스타일링

---

### 선택: Monaco Editor

| 평가 기준 | Monaco | CodeMirror 6 | Ace Editor |
|-----------|--------|--------------|------------|
| VS Code 호환 | O 동일 엔진 | X | X |
| 언어 지원 | O 풍부 | O 플러그인 | O |
| 번들 크기 | X 큼 (~2MB) | O 작음 | O 작음 |
| 사용자 친숙도 | O VS Code 경험 | - | - |

**선택 이유:**
1. **VS Code 경험**: 대부분의 개발자가 익숙한 UX
2. **언어 지원**: Python, Java, C++, JavaScript 모두 내장 지원

**번들 크기 완화:**
- Dynamic import로 초기 로딩 최적화
- 모바일은 MVP에서 지원 안함 (데스크톱 우선)

---

## 2. Backend

### 선택: Spring Boot 3.x (Java 17+)

| 평가 기준 | Spring Boot | Node.js (NestJS) | Go (Gin) | Python (FastAPI) |
|-----------|-------------|------------------|----------|------------------|
| 타입 안정성 | O 강타입 | - TS 필요 | O 강타입 | - 힌트 기반 |
| ORM | O JPA/Hibernate | O Prisma | - GORM | O SQLAlchemy |
| **메모리 사용** | **X 높음** | **O 낮음** | **O 최저** | **O 낮음** |
| 채용 시장 | O 한국 우세 | O | - | O |
| SQLite 지원 | O | O | O | O |

**선택 이유:**
1. **안정성**: 오랜 기간 검증된 프레임워크
2. **JPA + SQLite**: Hibernate의 SQLite 지원으로 쉬운 DB 연동
3. **한국 시장**: 백엔드 인력 풀이 풍부
4. **향후 확장**: 엔터프라이즈 기능 활용 용이

**메모리 최적화:**
```yaml
# application.yml - 메모리 제한 환경에서
server:
  tomcat:
    threads:
      max: 20
      min-spare: 5
```

**대안 검토 - Node.js (NestJS):**
- 메모리 사용량이 적어 저사양 VPS에 유리
- MVP 규모에서는 Spring Boot도 충분히 가볍게 운영 가능

---

### 선택: SQLite (MVP) → PostgreSQL (확장시)

| 평가 기준 | SQLite | PostgreSQL | MySQL |
|-----------|--------|------------|-------|
| **서버 비용** | **O ₩0** | **X 추가 비용** | **X 추가 비용** |
| 설정 복잡도 | O 없음 | X 서버 필요 | X 서버 필요 |
| 동시성 | X 제한적 | O 우수 | O 우수 |
| ACID | O | O | O |
| JSON 지원 | O 기본 | O JSONB | - |
| 백업 | O 파일 복사 | - 덤프 필요 | - 덤프 필요 |

**SQLite 선택 이유 (MVP):**
1. **비용 ₩0**: 별도 DB 서버 불필요
2. **단순성**: 설치/설정 없이 즉시 사용
3. **백업 용이**: 파일 복사만으로 백업 완료
4. **JPA 호환**: Spring Data JPA로 동일 코드 사용

**SQLite 제한 인지:**
- 동시 쓰기 제한 (WAL 모드로 완화)
- 대규모 트래픽 부적합
- **MVP 규모 (동시 10명)에서는 문제없음**

**마이그레이션 전략:**
```java
// application.yml - 환경별 DB 설정
spring:
  profiles:
    active: ${SPRING_PROFILES_ACTIVE:local}

---
spring:
  config:
    activate:
      on-profile: local
  datasource:
    url: jdbc:sqlite:./data/ct_system.db
    driver-class-name: org.sqlite.JDBC

---
spring:
  config:
    activate:
      on-profile: production-scaled
  datasource:
    url: jdbc:postgresql://localhost:5432/ct_system
    driver-class-name: org.postgresql.Driver
```

---

### 선택: In-Memory Queue (MVP) → Redis (확장시)

| 평가 기준 | In-Memory (BlockingQueue) | Redis | RabbitMQ |
|-----------|---------------------------|-------|----------|
| **서버 비용** | **O ₩0** | **X ~$10/월** | **X ~$15/월** |
| 설정 복잡도 | O 없음 | - 별도 서버 | X 복잡 |
| 영속성 | X 없음 | O | O |
| 분산 환경 | X | O | O |
| MVP 적합성 | O | - 오버스펙 | X 오버스펙 |

**In-Memory Queue 선택 이유:**
1. **비용 ₩0**: Redis 서버 불필요
2. **단순성**: 추가 인프라 없이 구현
3. **MVP 충분**: 단일 서버에서 분산 큐 불필요
4. **유실 허용**: 서버 재시작시 큐 유실 허용 (MVP)

**구현 방식:**
```java
// Spring @Async를 사용한 간단한 비동기 처리
@Service
public class SubmitService {

    @Async
    public CompletableFuture<SubmissionResult> processSubmission(SubmitRequest request) {
        // Judge0 호출 및 결과 처리
        return CompletableFuture.completedFuture(result);
    }
}
```

**Redis 도입 기준:**
1. 다중 서버 구성 필요시
2. 큐 메시지 영속성 필요시
3. 캐시 레이어 필요시

---

## 3. Execution Engine

### 선택: Judge0 (Self-hosted, 최소 구성)

| 평가 기준 | Judge0 | 자체 구현 | Sphere Engine | HackerRank API |
|-----------|--------|-----------|---------------|----------------|
| **구현 비용** | O 즉시 사용 | X 높음 | O | O |
| **운영 비용** | **O Self-hosted** | O 인프라만 | **X 유료** | **X 유료** |
| 커스터마이징 | O 오픈소스 | O 완전 | X 제한적 | X 제한적 |
| 보안 격리 | O isolate | - 직접 구현 | O | O |

**선택 이유:**
1. **비용 ₩0**: Self-hosted로 추가 비용 없음
2. **빠른 MVP**: 검증된 실행 엔진 즉시 사용
3. **오픈소스**: 필요시 커스터마이징 가능

**최소 리소스 구성:**
```yaml
# Judge0 환경 변수 (최소 설정)
environment:
  - MAX_NUMBER_OF_CONCURRENT_JOBS=2  # 워커 2개로 제한
  - MAX_QUEUE_SIZE=10                # 큐 사이즈 제한
  - MEMORY_LIMIT=256000              # 256MB로 제한
  - CPU_TIME_LIMIT=5                 # 5초 제한
```

---

## 4. Infrastructure

### 선택: Oracle Cloud Free Tier (권장) / 저가 VPS (대안)

| 평가 기준 | Oracle Cloud Free | Vultr ($5) | AWS (기존) |
|-----------|-------------------|------------|------------|
| **월 비용** | **O ₩0** | **O ~₩7,000** | **X ~₩180,000** |
| 스펙 | 4 OCPU, 24GB RAM | 1 vCPU, 1GB RAM | 다양 |
| 관리 편의성 | - | - | O 관리형 |
| 확장성 | X 제한적 | - 수동 | O 자동 |

**Oracle Cloud Free 선택 이유:**
1. **완전 무료**: ARM VM 4 OCPU, 24GB RAM 영구 무료
2. **충분한 스펙**: MVP에 과할 정도로 여유로운 리소스
3. **글로벌**: 한국 리전 지원

**저가 VPS 대안 (Oracle 사용 불가시):**
- Hetzner CX21: €4.35/월 (2 vCPU, 4GB RAM)
- Contabo VPS S: €5.99/월 (4 vCPU, 8GB RAM)

---

## 5. 결정 요약

### 비용 최적화 기술 스택

| 계층 | 선택 | 비용 | 핵심 이유 |
|------|------|------|-----------|
| Frontend Hosting | Vercel Free | **₩0** | 무료 호스팅, CDN |
| Frontend Framework | Next.js 14+ | - | SSR, Vercel 최적화 |
| UI Library | shadcn/ui | - | 번들 최소화 |
| Code Editor | Monaco | - | VS Code UX |
| Backend Framework | Spring Boot 3.x | - | 안정성, JPA |
| **Database** | **SQLite** | **₩0** | 서버 불필요 |
| **Message Queue** | **In-Memory** | **₩0** | Redis 불필요 |
| Execution Engine | Judge0 Self-hosted | **₩0** | 오픈소스 |
| **Server** | **Oracle Free/저가 VPS** | **₩0~7,000** | 무료/저가 |

### 월 비용 총계

| 구성 | 비용 |
|------|------|
| **Oracle Cloud Free** | **₩0** |
| **저가 VPS** | **~₩7,000** |
| 기존 AWS 구성 | ~₩180,000 |

---

## 6. 향후 재검토 시점

| 기술 | 재검토 트리거 | 대안 |
|------|---------------|------|
| SQLite | 동시 20명+ 빈번, DB 1GB+ | PostgreSQL |
| In-Memory Queue | 다중 서버 필요, 메시지 영속성 필요 | Redis |
| Oracle Free | 무료 티어 제한 도달 | Hetzner/Contabo |
| Spring Boot | 메모리 부족 이슈 | Node.js (NestJS) |
| Judge0 | 채용 플랫폼 확장 | gVisor 기반 자체 구현 |

---

## 7. 비용 vs 기능 트레이드오프

### 포기한 것들 (비용 절감을 위해)

| 기능 | 대안 | 영향 |
|------|------|------|
| 고가용성 | 단일 서버 | 다운타임 발생 가능 |
| 자동 스케일링 | 수동 확장 | 트래픽 급증시 느림 |
| 메시지 영속성 | 인메모리 큐 | 재시작시 큐 유실 |
| 관리형 DB | SQLite | 직접 백업 필요 |

### MVP에서 허용 가능한 이유

1. **유저 거의 없음**: 초기 MVP는 소수 사용자
2. **다운타임 허용**: 교육용 서비스로 24/7 가용성 불필요
3. **데이터 손실 최소**: 큐 유실되어도 재시도 가능
4. **비용 > 안정성**: MVP 검증이 우선
