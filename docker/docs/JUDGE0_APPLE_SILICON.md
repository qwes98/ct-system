# Judge0 Apple Silicon 호환성 가이드

Judge0 1.13.0은 `linux/amd64` 이미지만 제공하므로 Apple Silicon Mac에서 에뮬레이션으로 실행해야 합니다. 아래 설정이 필요합니다.

## Docker Desktop 필수 설정

Settings → General에서 다음 활성화:

- **Use Rosetta for x86_64/amd64 emulation on Apple Silicon** (필수)

> QEMU 에뮬레이션으로는 isolate의 `clone()` 시스템콜이 실패합니다.

## 알려진 이슈 및 해결책

### 1. cgroup v2 비호환

Judge0의 isolate 1.8.1은 cgroup v1을 요구하지만 macOS Docker Desktop은 cgroup v2만 지원합니다.

`docker-compose.yml`에 다음 환경변수가 설정되어 있어야 합니다:

```yaml
- ENABLE_PER_PROCESS_AND_THREAD_TIME_LIMIT=true
- ENABLE_PER_PROCESS_AND_THREAD_MEMORY_LIMIT=true
```

이 설정으로 isolate가 cgroup 대신 per-process 리소스 제한(`-m` 플래그)을 사용합니다.

### 2. 메모리 제한 증가 필요

Rosetta 에뮬레이션 환경에서는 가상 주소 공간이 더 많이 필요합니다.

```
JUDGE0_MEMORY_LIMIT=1536000  # 1.5GB (기본 256MB로는 부족)
```

### 3. Java 실행을 위한 추가 패치

JVM의 G1 GC가 Rosetta + isolate 환경에서 mmap 비호환 문제를 일으킵니다. SerialGC로 전환 + JVM 메모리 최소화가 필요합니다.

Judge0의 `seeds.rb`가 컨테이너 시작 시 언어 설정을 초기화하므로, **`docker compose up` 후 매번 패치 스크립트를 실행**해야 합니다:

```bash
bash scripts/init-judge0-java.sh
```

스크립트가 하는 일:
- Java(language_id=62)의 compile_cmd/run_cmd에 `JAVA_TOOL_OPTIONS` 주입
- SerialGC 사용, Metaspace/Heap/CodeCache 크기 최소화
- 패치 후 Java 실행 테스트로 검증

**참고**: Java 실행 시 stderr에 `Picked up JAVA_TOOL_OPTIONS: ...` 메시지가 출력됩니다. 정상 동작이며 백엔드에서 필터링 필요합니다.

## 시작 절차

```bash
cd docker
docker compose up -d
bash scripts/init-judge0-java.sh   # Java 패치 (매번 필요)
bash scripts/test-judge0.sh        # 검증 (선택)
```

## 프로덕션 환경 (Linux x86_64)

- cgroup v2 호환성 설정 불필요할 수 있음 (cgroup v1 사용 가능한 환경)
- Java 패치 불필요 (네이티브 x86_64이므로 Rosetta 미사용)
- `JUDGE0_MEMORY_LIMIT`은 프로덕션 요구에 맞게 조정
