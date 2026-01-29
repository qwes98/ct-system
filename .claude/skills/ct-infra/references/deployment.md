# 배포 스크립트 및 CI/CD

## 수동 배포 스크립트

```bash
#!/bin/bash
# /opt/scripts/deploy.sh

set -e

cd /opt/ct-system
git pull origin main

cd backend
./gradlew build -x test

sudo systemctl restart ct-backend

echo "Deployment completed at $(date)"
```

## GitHub Actions

```yaml
# .github/workflows/deploy.yml
name: Deploy Backend

on:
  push:
    branches: [main]
    paths:
      - 'backend/**'

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Deploy to Server
        uses: appleboy/ssh-action@v1.0.0
        with:
          host: ${{ secrets.SERVER_HOST }}
          username: ${{ secrets.SERVER_USER }}
          key: ${{ secrets.SERVER_SSH_KEY }}
          script: |
            cd /opt/ct-system
            git pull origin main
            cd backend
            ./gradlew build -x test
            sudo systemctl restart ct-backend
```

## GitHub Secrets 설정

| Secret | 설명 |
|--------|------|
| `SERVER_HOST` | 서버 IP 또는 도메인 |
| `SERVER_USER` | SSH 사용자 (예: ubuntu) |
| `SERVER_SSH_KEY` | 프라이빗 키 전체 내용 |

## 배포 체크리스트

1. `main` 브랜치로 머지
2. GitHub Actions 자동 실행
3. 서버에서 빌드 및 재시작
4. 헬스체크 확인: `curl localhost:8080/actuator/health`
