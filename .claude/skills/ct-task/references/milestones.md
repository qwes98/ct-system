# Milestone Quick Reference

마일스톤별 핵심 작업 요약. 상세 정보는 `docs/project/MILESTONE.md` 참조.

## M0: 프로젝트 셋업 (Week 1-2)

**산출물:**
- Git 저장소 + 브랜치 보호 + PR/Issue 템플릿
- docker-compose.yml (Judge0 포함)
- Spring Boot 프로젝트 (`backend/`)
- Next.js 프로젝트 (`frontend/`)
- CI/CD 기본 워크플로우

**완료 조건:**
- [ ] `docker-compose up`으로 전체 인프라 실행
- [ ] main 브랜치 보호 규칙 적용
- [ ] PR/Issue 템플릿 생성

---

## M1: 백엔드 기반 (Week 3-4)

**핵심 API:**
```
GET  /api/v1/problems
GET  /api/v1/problems/{id}
GET  /api/v1/problems/{id}/template?language=PYTHON
POST /api/v1/guest/token
```

**산출물:**
- Flyway 마이그레이션 (categories → problems → test_cases → templates → guest_sessions → submissions)
- JPA 엔티티 (Problem, TestCase, Template, GuestSession, Submission)
- 공통 응답 포맷 (ApiResponse) + 전역 예외 핸들러
- Problem/Guest API + 테스트

**완료 조건:**
- [ ] Swagger 문서화
- [ ] 단위 테스트 커버리지 70%+
- [ ] API 통합 테스트 통과

---

## M2: 프론트엔드 기반 (Week 5-6)

**핵심 페이지:**
```
/                     # 문제 리스트
/problems/[id]        # 문제 풀이
/submissions          # 제출 이력
```

**산출물:**
- Layout + Header + Footer
- shadcn/ui 공통 컴포넌트 (Button, Card, Badge, Skeleton)
- API 클라이언트 (Axios + React Query)
- 문제 리스트 페이지 + 페이지네이션
- Monaco Editor 통합 + 언어 선택

**완료 조건:**
- [ ] 문제 리스트 API 연동
- [ ] Monaco Editor 4개 언어 지원
- [ ] 반응형 레이아웃

---

## M3: Judge0 연동 (Week 7-8)

**핵심 API:**
```
POST /api/v1/run       # 샘플 테스트 실행
POST /api/v1/submit    # 전체 테스트 제출
GET  /api/v1/submissions/{id}  # 제출 상태 조회
```

**산출물:**
- Judge0 Docker 배포 + 보안 설정
- Judge0Client (WebClient 기반)
- 언어별 코드 래퍼 (Python, Java, C++, JavaScript)
- In-Memory BlockingQueue + Worker
- Run/Submit API + 테스트

**완료 조건:**
- [ ] 4개 언어 코드 실행 성공
- [ ] 상태 폴링 동작 (queued → running → done)
- [ ] 리소스 제한 동작 확인

---

## M4: 기능 통합 (Week 9-10)

**핵심 기능:**
- Run/Submit 버튼 + 결과 표시
- 상태 폴링 UI (2초 간격)
- 제출 이력 페이지
- 게스트 토큰 관리 (localStorage)

**완료 조건:**
- [ ] 전체 사용자 플로우 동작
- [ ] 에러 케이스 처리
- [ ] 크로스 브라우저 테스트

---

## M5: QA 및 출시 준비 (Week 11-12)

**테스트 범위:**
| 유형 | 범위 |
|------|------|
| 단위 테스트 | 백엔드 70%+ |
| 통합 테스트 | 주요 API 100% |
| E2E 테스트 | 핵심 플로우 |
| 부하 테스트 | Run 10, Submit 5 동시성 |
| 보안 테스트 | OWASP Top 10 |

**배포 준비:**
- Oracle Cloud / VPS 프로비저닝
- 환경변수 + 시크릿 설정
- 모니터링 + 알림 설정
- SQLite 백업 스크립트

**완료 조건:**
- [ ] P0/P1 버그 수정
- [ ] 성능 목표 달성 (P95 < 10초)
- [ ] 배포 리허설 완료

---

## M6: MVP 출시 (Week 13)

**배포 체크리스트:**
- [ ] DB 마이그레이션
- [ ] Frontend 배포 (Vercel)
- [ ] Backend + Judge0 배포
- [ ] DNS + SSL 설정
- [ ] 스모크 테스트

**운영 체크리스트:**
- [ ] 모니터링 대시보드
- [ ] 알림 동작 확인
- [ ] 롤백 절차 문서화
