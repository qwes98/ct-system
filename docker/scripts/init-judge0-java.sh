#!/bin/bash
# Judge0 Java 언어 설정 패치 (Apple Silicon 호환성)
#
# Judge0의 seeds.rb가 컨테이너 시작 시 모든 언어 설정을 초기화하므로,
# docker compose up 후 매번 실행해야 합니다.
#
# 사용법: ./init-judge0-java.sh [judge0_url] [db_container_name]
#
# 문제: JVM의 G1 GC가 Rosetta 에뮬레이션 + isolate 샌드박스 환경에서
#       mmap 패턴 비호환으로 크래시 발생
# 해결: SerialGC 사용 + JVM 메모리 설정 최소화

set -euo pipefail

JUDGE0_URL=${1:-"http://localhost:2358"}
DB_CONTAINER=${2:-"ct-judge0-db"}

BOLD='\033[1m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BOLD}=== Judge0 Java Language Patch (Apple Silicon) ===${NC}"

# Judge0 헬스체크 대기
echo -n "Waiting for Judge0 to be healthy..."
for i in $(seq 1 30); do
    if curl -sf "${JUDGE0_URL}/about" > /dev/null 2>&1; then
        echo -e " ${GREEN}Ready${NC}"
        break
    fi
    if [ "$i" -eq 30 ]; then
        echo -e " ${RED}Timeout${NC}"
        echo "ERROR: Judge0 is not responding at ${JUDGE0_URL}"
        exit 1
    fi
    echo -n "."
    sleep 2
done

# Java 언어 설정 패치
JAVA_TOOL_OPTIONS='-XX:+UseSerialGC -XX:MaxMetaspaceSize=64m -Xmx64m -XX:ReservedCodeCacheSize=16m -XX:CompressedClassSpaceSize=16m'

echo "Patching Java (language_id=62) compile/run commands..."
docker exec "$DB_CONTAINER" psql -U judge0 -d judge0 -c "
UPDATE languages SET
  compile_cmd = 'JAVA_TOOL_OPTIONS=\"${JAVA_TOOL_OPTIONS}\" /usr/local/openjdk13/bin/javac %s Main.java',
  run_cmd = 'JAVA_TOOL_OPTIONS=\"${JAVA_TOOL_OPTIONS}\" /usr/local/openjdk13/bin/java Main'
WHERE id = 62;
"

# 패치 확인
echo ""
echo -e "${BOLD}Verifying patch:${NC}"
docker exec "$DB_CONTAINER" psql -U judge0 -d judge0 -t -c \
  "SELECT 'compile_cmd: ' || compile_cmd FROM languages WHERE id = 62;"
docker exec "$DB_CONTAINER" psql -U judge0 -d judge0 -t -c \
  "SELECT 'run_cmd: ' || run_cmd FROM languages WHERE id = 62;"

# Java 실행 테스트
echo ""
echo -n "Testing Java execution..."
JAVA_RESULT=$(curl -sf -X POST "${JUDGE0_URL}/submissions?wait=true&fields=stdout,status" \
    -H "Content-Type: application/json" \
    -d '{"source_code":"public class Main { public static void main(String[] args) { System.out.println(42); } }","language_id":62,"stdin":""}' 2>/dev/null || echo '{"status":{"id":0}}')

JAVA_STATUS=$(echo "$JAVA_RESULT" | jq -r '.status.id // 0')
if [ "$JAVA_STATUS" = "3" ]; then
    echo -e " ${GREEN}PASS${NC} (Accepted)"
else
    JAVA_DESC=$(echo "$JAVA_RESULT" | jq -r '.status.description // "Unknown"')
    echo -e " ${RED}FAIL${NC} (status: $JAVA_DESC)"
    echo -e "${YELLOW}Note: You may need to increase JUDGE0_MEMORY_LIMIT in .env (recommended: 1536000)${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}${BOLD}Java patch applied successfully!${NC}"
echo -e "Note: This patch must be re-applied after every 'docker compose up'"
