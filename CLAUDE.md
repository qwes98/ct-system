# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Coding Test Practice Platform (코딩테스트 연습 플랫폼)** - A web-based MVP platform for coding interview preparation targeting individual learners.

**Status**: Pre-implementation phase (PRD complete, no code yet)

## Cost Target

**월 1만원 이하 (~$7-8 USD)** - 무료/저가 인프라 구성으로 최소 비용 운영

## Planned Technology Stack

### Frontend
- Framework: Next.js (Vercel Free Tier 호스팅)
- UI Library: shadcn/ui
- Code Editor: Monaco Editor
- Languages supported: Python, Java, C++, JavaScript

### Backend
- Framework: Spring Boot (Java)
- Database: **SQLite** (MVP) → PostgreSQL (확장시)
- Message Queue: **In-Memory Queue** (MVP) → Redis (확장시)
- Code Execution: Judge0 (self-hosted, minimal config)

### Infrastructure
- **권장**: Oracle Cloud Free Tier (4 OCPU, 24GB RAM - 완전 무료)
- **대안**: 저가 VPS (Hetzner, Contabo - 월 ~$5-6)

## Architecture

```
Vercel (Next.js Frontend) → Single VM (Spring Boot + Judge0)
                                    ↓
                              SQLite (File DB)
```

### Key Components
1. **Frontend**: Monaco-based code editor, problem viewer, submission UI (Vercel Free)
2. **Backend API**: Problem/template endpoints, submission state machine (queued→running→done), Judge0 coordination
3. **Execution Engine**: Judge0 for sandboxed code execution (Docker, minimal workers)
4. **Queue System**: In-memory BlockingQueue for async Submit (no Redis needed)

### Concurrency Targets (MVP - 축소됨)
- Run: **10 concurrent**
- Submit: **5 concurrent**

> Note: 유저가 거의 없는 MVP 단계에서는 낮은 동시성으로 충분

## MVP Feature Scope

### Included
- Problem list/details (description, constraints, examples)
- Multi-language code editor with function-form templates
- **Run**: Execute sample tests only (immediate feedback)
- **Submit**: Execute all tests (sample + hidden), save history
- Submission status: queued → running → done
- Guest-based submission history (device/token based)
- Result display: pass/fail + error indicator only (no detailed logs)

### Excluded
- User authentication (guest only for MVP)
- Leaderboards/rankings
- Partial scoring
- Plagiarism detection
- Detailed error log exposure
- **고가용성** (단일 서버로 운영)
- **자동 스케일링**

## Problem Format Policy

- All problems are **function-form only** (e.g., `solve(input) -> output`)
- Platform provides language-specific template code with function signatures
- **Sample tests**: Public (visible during Run)
- **Hidden tests**: Private (Submit only)
- No exposure of stderr, compilation logs, or failed test case details

## Security Requirements (MVP)

- Container-based isolation (Judge0 default)
- Network blocking (all directions)
- Resource limits: 1 vCPU, **256MB RAM**, 5s timeout
- Simple rate limiting by IP
- Code size and input size restrictions

## Success Metrics

- **Submission completion rate**: 90%+
- **Submit response time**: <10 seconds (P95)
- **API availability**: 95%+ (MVP에서 완화된 목표)

## Cost Breakdown

| Component | Option A (Free) | Option B (Low-cost) |
|-----------|-----------------|---------------------|
| Frontend | Vercel Free | Vercel Free |
| Backend Server | Oracle Cloud Free | VPS ~$5-6/월 |
| Database | SQLite | SQLite |
| Total | **₩0/월** | **~₩7,000/월** |

## Reference

See `/docs/PRD.md` for full product requirements in Korean.
See `/docs/architecture/INFRASTRUCTURE.md` for detailed infrastructure setup.
See `/docs/architecture/TECH_STACK_DECISION.md` for technology choices rationale.
