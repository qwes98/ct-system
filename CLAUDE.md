# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Coding Test Practice Platform (코딩테스트 연습 플랫폼)** - A web-based MVP platform for coding interview preparation targeting individual learners.

**Status**: Pre-implementation phase (PRD complete, no code yet)

## Planned Technology Stack

### Frontend
- Framework: Next.js
- UI Library: shadcn/ui
- Code Editor: Monaco Editor
- Languages supported: Python, Java, C++, JavaScript

### Backend
- Framework: Spring Boot (Java)
- Database: PostgreSQL
- Message Queue: Redis
- Code Execution: Judge0 (self-hosted)

## Architecture

```
Next.js Frontend → Spring Boot API → Judge0 Execution Engine
                        ↓
                PostgreSQL + Redis Queue
```

### Key Components
1. **Frontend**: Monaco-based code editor, problem viewer, submission UI
2. **Backend API**: Problem/template endpoints, submission state machine (queued→running→done), Judge0 coordination
3. **Execution Engine**: Judge0 for sandboxed code execution with container isolation
4. **Queue System**: Redis for async Submit processing (Run is synchronous)

### Concurrency Targets
- Run: 50 concurrent
- Submit: 20 concurrent (with horizontal scaling via queue workers)

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

## Problem Format Policy

- All problems are **function-form only** (e.g., `solve(input) -> output`)
- Platform provides language-specific template code with function signatures
- **Sample tests**: Public (visible during Run)
- **Hidden tests**: Private (Submit only)
- No exposure of stderr, compilation logs, or failed test case details

## Security Requirements (MVP)

- Container-based isolation (Judge0 default)
- Network blocking (all directions)
- Resource limits: 1 vCPU, 512MB RAM, 2-5s timeout (configurable per problem)
- Rate limiting by IP/session
- Code size and input size restrictions

## Success Metrics

- **Submission completion rate**: 90%+
- **Submit response time**: <10 seconds (P95)

## Reference

See `/docs/PRD.md` for full product requirements in Korean.
