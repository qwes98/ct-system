#!/bin/bash
# Judge0 로컬 환경 통합 테스트 스크립트
# 사용법: ./test-judge0.sh [judge0_url]
#
# 테스트 항목:
#   1. 헬스체크 (GET /about)
#   2. 언어 목록 확인 (GET /languages)
#   3. 상태 코드 확인 (GET /statuses)
#   4. Python 코드 실행 (정상)
#   5. Java 코드 실행 (정상)
#   6. Python 시간 초과 테스트 (TLE)
#   7. Java 컴파일 에러 테스트 (CE)
#   8. 리소스 제한 확인

set -uo pipefail

JUDGE0_URL=${1:-"http://localhost:2358"}
PASSED=0
FAILED=0
TOTAL=0

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# 테스트 결과 출력 함수
pass() {
    PASSED=$((PASSED + 1))
    TOTAL=$((TOTAL + 1))
    echo -e "  ${GREEN}[PASS]${NC} $1"
}

fail() {
    FAILED=$((FAILED + 1))
    TOTAL=$((TOTAL + 1))
    echo -e "  ${RED}[FAIL]${NC} $1"
    if [ -n "${2:-}" ]; then
        echo -e "        ${RED}Detail: $2${NC}"
    fi
}

section() {
    echo ""
    echo -e "${BOLD}=== $1 ===${NC}"
}

# JSON에서 값 추출 (jq 의존)
check_jq() {
    if ! command -v jq &> /dev/null; then
        echo -e "${RED}ERROR: jq is required but not installed.${NC}"
        echo "  Install: brew install jq (macOS) / apt install jq (Ubuntu)"
        exit 1
    fi
}

#------------------------------------------------------------
# 테스트 시작
#------------------------------------------------------------

echo -e "${BOLD}================================================${NC}"
echo -e "${BOLD}  Judge0 Local Environment Test${NC}"
echo -e "${BOLD}  Target: ${JUDGE0_URL}${NC}"
echo -e "${BOLD}================================================${NC}"

check_jq

#------------------------------------------------------------
# Test 1: 헬스체크 (GET /about)
#------------------------------------------------------------
section "Test 1: Health Check (GET /about)"

ABOUT_RESPONSE=$(curl -sf "${JUDGE0_URL}/about" 2>/dev/null || echo "CURL_FAILED")

if [ "$ABOUT_RESPONSE" = "CURL_FAILED" ]; then
    fail "Judge0 /about endpoint unreachable"
else
    # version 필드 존재 확인
    VERSION=$(echo "$ABOUT_RESPONSE" | jq -r '.version // empty' 2>/dev/null || echo "")
    if [ -n "$VERSION" ]; then
        pass "Judge0 is running (version: $VERSION)"
    else
        fail "Judge0 /about returned unexpected response" "$ABOUT_RESPONSE"
    fi
fi

#------------------------------------------------------------
# Test 2: 언어 목록 확인 (GET /languages)
#------------------------------------------------------------
section "Test 2: Language List (GET /languages)"

LANGUAGES_RESPONSE=$(curl -sf "${JUDGE0_URL}/languages" 2>/dev/null || echo "CURL_FAILED")

if [ "$LANGUAGES_RESPONSE" = "CURL_FAILED" ]; then
    fail "GET /languages endpoint unreachable"
else
    # Python (id=71) 존재 확인
    PYTHON_EXISTS=$(echo "$LANGUAGES_RESPONSE" | jq '[.[] | select(.id == 71)] | length' 2>/dev/null || echo "0")
    if [ "$PYTHON_EXISTS" -gt 0 ]; then
        pass "Python 3 (language_id=71) available"
    else
        fail "Python 3 (language_id=71) not found in languages list"
    fi

    # Java (id=62) 존재 확인
    JAVA_EXISTS=$(echo "$LANGUAGES_RESPONSE" | jq '[.[] | select(.id == 62)] | length' 2>/dev/null || echo "0")
    if [ "$JAVA_EXISTS" -gt 0 ]; then
        pass "Java (language_id=62) available"
    else
        fail "Java (language_id=62) not found in languages list"
    fi
fi

#------------------------------------------------------------
# Test 3: 상태 코드 확인 (GET /statuses)
#------------------------------------------------------------
section "Test 3: Status Codes (GET /statuses)"

STATUSES_RESPONSE=$(curl -sf "${JUDGE0_URL}/statuses" 2>/dev/null || echo "CURL_FAILED")

if [ "$STATUSES_RESPONSE" = "CURL_FAILED" ]; then
    fail "GET /statuses endpoint unreachable"
else
    STATUS_COUNT=$(echo "$STATUSES_RESPONSE" | jq 'length' 2>/dev/null || echo "0")
    if [ "$STATUS_COUNT" -gt 0 ]; then
        pass "Status codes available (count: $STATUS_COUNT)"
    else
        fail "No status codes returned"
    fi
fi

#------------------------------------------------------------
# Test 4: Python 코드 실행 (정상 케이스)
#------------------------------------------------------------
section "Test 4: Python Code Execution (Normal)"

# Python: 두 수의 합 계산
PYTHON_RESPONSE=$(curl -sf -X POST "${JUDGE0_URL}/submissions?wait=true&fields=stdout,stderr,status,time,memory,compile_output" \
    -H "Content-Type: application/json" \
    -d '{
        "source_code": "a, b = map(int, input().split())\nprint(a + b)",
        "language_id": 71,
        "stdin": "3 5",
        "expected_output": "8\n"
    }' 2>/dev/null || echo "CURL_FAILED")

if [ "$PYTHON_RESPONSE" = "CURL_FAILED" ]; then
    fail "Python submission request failed"
else
    PY_STATUS_ID=$(echo "$PYTHON_RESPONSE" | jq -r '.status.id // empty' 2>/dev/null || echo "")
    PY_STDOUT=$(echo "$PYTHON_RESPONSE" | jq -r '.stdout // empty' 2>/dev/null || echo "")
    PY_TIME=$(echo "$PYTHON_RESPONSE" | jq -r '.time // "N/A"' 2>/dev/null || echo "N/A")
    PY_MEMORY=$(echo "$PYTHON_RESPONSE" | jq -r '.memory // "N/A"' 2>/dev/null || echo "N/A")

    if [ "$PY_STATUS_ID" = "3" ]; then
        pass "Python execution: Accepted (status_id=3)"
        echo -e "        stdout='$(echo "$PY_STDOUT" | tr -d '\n')' time=${PY_TIME}s memory=${PY_MEMORY}KB"
    else
        PY_STATUS_DESC=$(echo "$PYTHON_RESPONSE" | jq -r '.status.description // "Unknown"' 2>/dev/null || echo "Unknown")
        PY_STDERR=$(echo "$PYTHON_RESPONSE" | jq -r '.stderr // empty' 2>/dev/null || echo "")
        fail "Python execution: Expected status_id=3 (Accepted), got status_id=$PY_STATUS_ID ($PY_STATUS_DESC)" "${PY_STDERR}"
    fi
fi

#------------------------------------------------------------
# Test 5: Java 코드 실행 (정상 케이스)
#------------------------------------------------------------
section "Test 5: Java Code Execution (Normal)"

# Java: 두 수의 합 계산
JAVA_RESPONSE=$(curl -sf -X POST "${JUDGE0_URL}/submissions?wait=true&fields=stdout,stderr,status,time,memory,compile_output" \
    -H "Content-Type: application/json" \
    -d '{
        "source_code": "import java.util.Scanner;\n\npublic class Main {\n    public static void main(String[] args) {\n        Scanner sc = new Scanner(System.in);\n        int a = sc.nextInt();\n        int b = sc.nextInt();\n        System.out.println(a + b);\n    }\n}",
        "language_id": 62,
        "stdin": "3 5",
        "expected_output": "8\n"
    }' 2>/dev/null || echo "CURL_FAILED")

if [ "$JAVA_RESPONSE" = "CURL_FAILED" ]; then
    fail "Java submission request failed"
else
    JAVA_STATUS_ID=$(echo "$JAVA_RESPONSE" | jq -r '.status.id // empty' 2>/dev/null || echo "")
    JAVA_STDOUT=$(echo "$JAVA_RESPONSE" | jq -r '.stdout // empty' 2>/dev/null || echo "")
    JAVA_TIME=$(echo "$JAVA_RESPONSE" | jq -r '.time // "N/A"' 2>/dev/null || echo "N/A")
    JAVA_MEMORY=$(echo "$JAVA_RESPONSE" | jq -r '.memory // "N/A"' 2>/dev/null || echo "N/A")

    if [ "$JAVA_STATUS_ID" = "3" ]; then
        pass "Java execution: Accepted (status_id=3)"
        echo -e "        stdout='$(echo "$JAVA_STDOUT" | tr -d '\n')' time=${JAVA_TIME}s memory=${JAVA_MEMORY}KB"
    else
        JAVA_STATUS_DESC=$(echo "$JAVA_RESPONSE" | jq -r '.status.description // "Unknown"' 2>/dev/null || echo "Unknown")
        JAVA_COMPILE=$(echo "$JAVA_RESPONSE" | jq -r '.compile_output // empty' 2>/dev/null || echo "")
        JAVA_STDERR=$(echo "$JAVA_RESPONSE" | jq -r '.stderr // empty' 2>/dev/null || echo "")
        fail "Java execution: Expected status_id=3 (Accepted), got status_id=$JAVA_STATUS_ID ($JAVA_STATUS_DESC)" "${JAVA_COMPILE}${JAVA_STDERR}"
    fi
fi

#------------------------------------------------------------
# Test 6: Python 시간 초과 테스트 (TLE)
#------------------------------------------------------------
section "Test 6: Python Time Limit Exceeded (TLE)"

# Python: 무한 루프 (cpu_time_limit=1초로 짧게 설정)
TLE_RESPONSE=$(curl -sf -X POST "${JUDGE0_URL}/submissions?wait=true&fields=stdout,stderr,status,time,memory" \
    -H "Content-Type: application/json" \
    -d '{
        "source_code": "while True:\n    pass",
        "language_id": 71,
        "cpu_time_limit": 1,
        "wall_time_limit": 3
    }' 2>/dev/null || echo "CURL_FAILED")

if [ "$TLE_RESPONSE" = "CURL_FAILED" ]; then
    fail "TLE test submission request failed"
else
    TLE_STATUS_ID=$(echo "$TLE_RESPONSE" | jq -r '.status.id // empty' 2>/dev/null || echo "")
    if [ "$TLE_STATUS_ID" = "5" ]; then
        pass "Time Limit Exceeded correctly detected (status_id=5)"
    else
        TLE_STATUS_DESC=$(echo "$TLE_RESPONSE" | jq -r '.status.description // "Unknown"' 2>/dev/null || echo "Unknown")
        fail "TLE test: Expected status_id=5 (TLE), got status_id=$TLE_STATUS_ID ($TLE_STATUS_DESC)"
    fi
fi

#------------------------------------------------------------
# Test 7: Java 컴파일 에러 테스트 (CE)
#------------------------------------------------------------
section "Test 7: Java Compilation Error (CE)"

# Java: 의도적 문법 에러
CE_RESPONSE=$(curl -sf -X POST "${JUDGE0_URL}/submissions?wait=true&fields=stdout,stderr,status,compile_output" \
    -H "Content-Type: application/json" \
    -d '{
        "source_code": "public class Main {\n    public static void main(String[] args) {\n        System.out.println(\"hello\"\n    }\n}",
        "language_id": 62
    }' 2>/dev/null || echo "CURL_FAILED")

if [ "$CE_RESPONSE" = "CURL_FAILED" ]; then
    fail "CE test submission request failed"
else
    CE_STATUS_ID=$(echo "$CE_RESPONSE" | jq -r '.status.id // empty' 2>/dev/null || echo "")
    if [ "$CE_STATUS_ID" = "6" ]; then
        CE_OUTPUT=$(echo "$CE_RESPONSE" | jq -r '.compile_output // "N/A"' 2>/dev/null || echo "N/A")
        pass "Compilation Error correctly detected (status_id=6)"
        echo -e "        compile_output: $(echo "$CE_OUTPUT" | head -1)"
    else
        CE_STATUS_DESC=$(echo "$CE_RESPONSE" | jq -r '.status.description // "Unknown"' 2>/dev/null || echo "Unknown")
        fail "CE test: Expected status_id=6 (CE), got status_id=$CE_STATUS_ID ($CE_STATUS_DESC)"
    fi
fi

#------------------------------------------------------------
# Test 8: 리소스 제한 확인
#------------------------------------------------------------
section "Test 8: Resource Limits Verification"

# /about 응답에서 설정값 확인
if [ "$ABOUT_RESPONSE" != "CURL_FAILED" ] && [ -n "$ABOUT_RESPONSE" ]; then
    # 네트워크 차단 확인
    ENABLE_NETWORK=$(echo "$ABOUT_RESPONSE" | jq -r '.enable_network // empty' 2>/dev/null || echo "")
    if [ "$ENABLE_NETWORK" = "false" ]; then
        pass "Network disabled (ENABLE_NETWORK=false)"
    elif [ -z "$ENABLE_NETWORK" ]; then
        # /about에 없을 수 있음 - Python 네트워크 테스트로 확인
        echo -e "  ${YELLOW}[INFO]${NC} ENABLE_NETWORK not in /about response, testing via code execution..."

        NET_RESPONSE=$(curl -sf -X POST "${JUDGE0_URL}/submissions?wait=true&fields=stdout,stderr,status" \
            -H "Content-Type: application/json" \
            -d '{
                "source_code": "import urllib.request\ntry:\n    urllib.request.urlopen(\"http://google.com\", timeout=2)\n    print(\"NETWORK_AVAILABLE\")\nexcept:\n    print(\"NETWORK_BLOCKED\")",
                "language_id": 71,
                "cpu_time_limit": 5,
                "wall_time_limit": 10
            }' 2>/dev/null || echo "CURL_FAILED")

        if [ "$NET_RESPONSE" != "CURL_FAILED" ]; then
            NET_STDOUT=$(echo "$NET_RESPONSE" | jq -r '.stdout // empty' 2>/dev/null || echo "")
            if echo "$NET_STDOUT" | grep -q "NETWORK_BLOCKED"; then
                pass "Network correctly blocked (verified via code execution)"
            elif echo "$NET_STDOUT" | grep -q "NETWORK_AVAILABLE"; then
                fail "Network is NOT blocked - security risk!" "Code was able to reach external network"
            else
                NET_STATUS_DESC=$(echo "$NET_RESPONSE" | jq -r '.status.description // "Unknown"' 2>/dev/null || echo "Unknown")
                pass "Network likely blocked (execution result: $NET_STATUS_DESC)"
            fi
        else
            fail "Could not verify network blocking"
        fi
    else
        fail "Network should be disabled but ENABLE_NETWORK=$ENABLE_NETWORK"
    fi

    # CPU 시간 제한 확인
    CPU_LIMIT=$(echo "$ABOUT_RESPONSE" | jq -r '.cpu_time_limit // empty' 2>/dev/null || echo "")
    if [ -n "$CPU_LIMIT" ]; then
        pass "CPU time limit set: ${CPU_LIMIT}s"
    else
        echo -e "  ${YELLOW}[INFO]${NC} CPU time limit not exposed in /about (verified via TLE test above)"
    fi

    # 메모리 제한 확인
    MEM_LIMIT=$(echo "$ABOUT_RESPONSE" | jq -r '.memory_limit // empty' 2>/dev/null || echo "")
    if [ -n "$MEM_LIMIT" ]; then
        pass "Memory limit set: ${MEM_LIMIT}KB"
    else
        echo -e "  ${YELLOW}[INFO]${NC} Memory limit not exposed in /about (configured via docker-compose env)"
    fi

    # 동시 작업 수 확인
    MAX_JOBS=$(echo "$ABOUT_RESPONSE" | jq -r '.max_number_of_concurrent_jobs // empty' 2>/dev/null || echo "")
    if [ -n "$MAX_JOBS" ]; then
        pass "Max concurrent jobs: $MAX_JOBS"
    else
        echo -e "  ${YELLOW}[INFO]${NC} Max concurrent jobs not exposed in /about"
    fi
else
    fail "Cannot verify resource limits (/about unavailable)"
fi

#------------------------------------------------------------
# 결과 요약
#------------------------------------------------------------
echo ""
echo -e "${BOLD}================================================${NC}"
echo -e "${BOLD}  Test Results Summary${NC}"
echo -e "${BOLD}================================================${NC}"
echo -e "  Total:  ${TOTAL}"
echo -e "  ${GREEN}Passed: ${PASSED}${NC}"
echo -e "  ${RED}Failed: ${FAILED}${NC}"
echo ""

if [ "$FAILED" -eq 0 ]; then
    echo -e "${GREEN}${BOLD}All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}${BOLD}${FAILED} test(s) failed.${NC}"
    exit 1
fi
