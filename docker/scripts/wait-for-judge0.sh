#!/bin/bash
# Judge0 서비스 기동 대기 스크립트
# 사용법: ./wait-for-judge0.sh [timeout_seconds] [judge0_url]

set -euo pipefail

TIMEOUT=${1:-120}
JUDGE0_URL=${2:-"http://localhost:2358"}
INTERVAL=5
ELAPSED=0

if ! [[ "$TIMEOUT" =~ ^[0-9]+$ ]]; then
    echo "ERROR: timeout must be a positive integer, got: $TIMEOUT"
    exit 1
fi

echo "Waiting for Judge0 at ${JUDGE0_URL} (timeout: ${TIMEOUT}s)..."

while [ "$ELAPSED" -lt "$TIMEOUT" ]; do
    if curl -sf "${JUDGE0_URL}/about" > /dev/null 2>&1; then
        echo "Judge0 is ready! (took ${ELAPSED}s)"
        exit 0
    fi
    sleep "$INTERVAL"
    ELAPSED=$((ELAPSED + INTERVAL))
    echo "  Still waiting... (${ELAPSED}s / ${TIMEOUT}s)"
done

echo "ERROR: Judge0 did not become ready within ${TIMEOUT}s"
exit 1
