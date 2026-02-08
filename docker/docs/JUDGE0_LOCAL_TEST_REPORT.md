# Judge0 로컬 환경 테스트 진단 보고서

## 테스트 결과 요약

| # | 테스트 | 결과 |
|---|--------|------|
| 1 | Health Check (GET /about) | PASS |
| 2 | Language List (GET /languages) | PASS |
| 3 | Status Codes (GET /statuses) | PASS |
| 4 | Python Code Execution (Normal) | PASS |
| 5 | Java Code Execution (Normal) | PASS |
| 6 | Python Time Limit Exceeded (TLE) | PASS |
| 7 | Java Compilation Error (CE) | PASS |
| 8 | Resource Limits Verification | PASS |

**9/9 PASS, 0/9 FAIL**

---

## 문제 1: cgroup v2 비호환 (해결됨)

**증상**: 모든 코드 실행이 `status_id=13 (Internal Error)` 반환

```
Failed to create control group /sys/fs/cgroup/memory/box-N/: No such file or directory
```

**원인**: Judge0 1.13.0의 isolate 1.8.1은 cgroup v1 (`/sys/fs/cgroup/memory/`) 필요. macOS Docker Desktop은 cgroup v2만 지원.

**시도한 해결책**:
- `deprecatedCgroupv1: true` 설정 → Docker Desktop 20.10.24에서 **무시됨** (known regression)
- Docker VM 내부에서 cgroup v1 수동 마운트 → 권한 거부

**적용한 해결책**: `docker-compose.yml`에 환경변수 추가

```yaml
- ENABLE_PER_PROCESS_AND_THREAD_TIME_LIMIT=true
- ENABLE_PER_PROCESS_AND_THREAD_MEMORY_LIMIT=true
```

이 설정으로 isolate가 `--cg` 플래그 대신 per-process 리소스 제한(`-m` 플래그)을 사용하여 cgroup v1 불필요.

---

## 문제 2: Apple Silicon QEMU 에뮬레이션 (해결됨)

**증상**: `Cannot run proxy, clone failed: Invalid argument`

**원인**: Judge0 이미지는 `linux/amd64`만 제공. QEMU 에뮬레이션에서 isolate의 `clone()` 시스템 콜 (namespace 생성)이 실패.

**적용한 해결책**: Docker Desktop에서 Rosetta 에뮬레이션 활성화

```json
"useVirtualizationFrameworkRosetta": true
```

Rosetta가 QEMU보다 x86 시스템콜을 더 정확히 에뮬레이션.

---

## 문제 3: 메모리 제한 (해결됨)

**증상**: Python 실행시 `rosetta error: mmap_anonymous_rw mmap failed, size=1000`

**원인**: 기본 `MEMORY_LIMIT=256000` (256MB)이 Rosetta 변환 레이어의 메모리 오버헤드를 감당하지 못함. isolate의 `-m` 플래그가 프로세스의 가상 주소 공간(RLIMIT_AS)을 제한하는데, Rosetta가 추가 mmap 매핑 필요.

**적용한 해결책**: `.env`에서 메모리 증가

```
JUDGE0_MEMORY_LIMIT=1536000  # 256MB → 1.5GB (Java 가상 주소 공간 확보)
```

---

## 문제 4: Java 실행 실패 (해결됨)

**증상**: Java 컴파일 단계에서 JVM 크래시

```
Internal Error (g1PageBasedVirtualSpace.cpp:43)
guarantee(rs.is_reserved()) failed
rosetta error: mmap_anonymous_rw mmap failed, size=1000
```

**원인**: 두 가지 문제의 복합:
1. JVM(OpenJDK 13.0.1)의 **G1 GC**가 Rosetta 에뮬레이션 환경에서 특정 mmap 패턴을 사용하는데, isolate 샌드박스 내부에서 Rosetta가 이를 처리하지 못함.
2. isolate의 `-m` 플래그(per-process 메모리 제한)가 가상 주소 공간(RLIMIT_AS)을 제한하는데, JVM은 **최소 ~1.05GB**의 가상 주소 공간이 필요. (실제 물리 메모리 사용량은 ~34MB에 불과)

**시도한 해결책 (실패)**:

| 시도 | 결과 |
|------|------|
| `MAX_MEMORY_LIMIT=10240000` (10GB) | 실패 - 메모리 크기만으로는 해결 불가 |
| `-J-XX:+UseSerialGC` (G1 GC 비활성화) | 실패 - MetaspaceSize 할당 실패 |
| `-J-XX:MaxMetaspaceSize=64m -J-Xmx256m` | 실패 - 동일한 Rosetta mmap 에러 |
| Rosetta 비활성화 (QEMU로 복귀) | 실패 - clone() Invalid argument |

**적용한 해결책**: G1 GC 비활성화 + JVM 메모리 설정 최소화 + 메모리 제한 증가의 **3가지 조합**

1. **Judge0 DB에서 Java 언어 설정 패치** (SerialGC + 최소 JVM 메모리):

```sql
UPDATE languages SET
  compile_cmd = 'JAVA_TOOL_OPTIONS="-XX:+UseSerialGC -XX:MaxMetaspaceSize=64m -Xmx64m -XX:ReservedCodeCacheSize=16m -XX:CompressedClassSpaceSize=16m" /usr/local/openjdk13/bin/javac %s Main.java',
  run_cmd = 'JAVA_TOOL_OPTIONS="-XX:+UseSerialGC -XX:MaxMetaspaceSize=64m -Xmx64m -XX:ReservedCodeCacheSize=16m -XX:CompressedClassSpaceSize=16m" /usr/local/openjdk13/bin/java Main'
WHERE id = 62;
```

2. **메모리 제한 증가** (`.env`):

```
JUDGE0_MEMORY_LIMIT=1536000  # 1GB → 1.5GB (JVM 가상 주소 공간 확보)
```

**핵심 인사이트**:
- 이전 시도에서 SerialGC만 적용했을 때 실패한 이유: `MEMORY_LIMIT=1024000`이 JVM 최소 가상 주소 공간(~1.05GB)보다 작았음
- SerialGC + 메모리 설정 최소화 + 충분한 MEMORY_LIMIT의 조합이 필요
- `JAVA_TOOL_OPTIONS` 환경변수로 JVM 플래그를 전달하면 javac/java 모두에 적용됨

**주의사항**:
- Judge0의 `seeds.rb`가 컨테이너 시작 시 언어 설정을 초기화하므로, `docker compose up` 후 매번 `scripts/init-judge0-java.sh` 실행 필요
- Java 실행 시 stderr에 `Picked up JAVA_TOOL_OPTIONS: ...` 메시지가 출력됨 (정상 동작, 백엔드에서 필터링 필요)

---

## 환경 정보

| 항목 | 값 |
|------|-----|
| Host | macOS Darwin 25.2.0 (Apple Silicon) |
| Docker Desktop | Engine 20.10.24 |
| Judge0 | 1.13.0 (linux/amd64) |
| isolate | 1.8.1 |
| JVM | OpenJDK 13.0.1 |
| cgroup | v2 (v1 unavailable) |

---

## 변경된 파일

1. **`docker/docker-compose.yml`**: cgroup v2 호환성 설정 + 메모리 제한 증가
2. **`docker/.env`**: `JUDGE0_MEMORY_LIMIT` 1536000으로 증가 (Java 가상 주소 공간 확보)
3. **`docker/scripts/init-judge0-java.sh`**: Apple Silicon용 Java 언어 설정 패치 스크립트 (신규)
4. **Docker Desktop 설정**: `useVirtualizationFrameworkRosetta: true`, `deprecatedCgroupv1: true`

---

## Apple Silicon 사용자 설정 가이드

```bash
# 1. Docker compose 시작
cd docker
docker compose up -d

# 2. Judge0 헬스체크 대기 후 Java 패치 적용
bash scripts/init-judge0-java.sh

# 3. 테스트 실행
bash scripts/test-judge0.sh
```

> **Note**: `init-judge0-java.sh`는 `docker compose up` 후 매번 실행해야 합니다.
> Judge0의 `seeds.rb`가 컨테이너 시작 시 언어 설정을 초기화하기 때문입니다.

---

## 권장사항

1. **프로덕션 환경 (Linux x86_64)**: 모든 테스트 정상 통과 예상. cgroup v2 호환성 설정 및 Java 패치 불필요할 수 있음.
2. **macOS 개발 환경 (Apple Silicon)**: `docker compose up` 후 반드시 `init-judge0-java.sh` 실행. Java stderr에 `JAVA_TOOL_OPTIONS` 메시지 출력은 정상.
3. **장기적**: Judge0가 isolate 2.0+ (cgroup v2 지원) 및 ARM64 이미지를 채택하면 대부분 문제 해결 예상.
