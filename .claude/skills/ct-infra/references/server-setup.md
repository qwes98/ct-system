# 서버 초기화 및 Nginx 설정

## Oracle Cloud / Ubuntu 22.04 초기화

```bash
#!/bin/bash
# server-init.sh

# Docker 설치
sudo apt update
sudo apt install -y docker.io docker-compose
sudo usermod -aG docker $USER

# Java 17 설치
sudo apt install -y openjdk-17-jdk

# Nginx 설치
sudo apt install -y nginx certbot python3-certbot-nginx

# 방화벽 설정 (Oracle Cloud)
sudo iptables -I INPUT 6 -m state --state NEW -p tcp --dport 80 -j ACCEPT
sudo iptables -I INPUT 6 -m state --state NEW -p tcp --dport 443 -j ACCEPT
sudo iptables -I INPUT 6 -m state --state NEW -p tcp --dport 8080 -j ACCEPT
sudo netfilter-persistent save

# 디렉토리 생성
sudo mkdir -p /opt/ct-system/{data,logs,backups}
sudo chown -R $USER:$USER /opt/ct-system
```

## Nginx 리버스 프록시

```nginx
# /etc/nginx/sites-available/ct-api
server {
    listen 80;
    server_name api.example.com;

    location / {
        proxy_pass http://localhost:8080;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

## SSL 인증서 (Let's Encrypt)

```bash
sudo ln -s /etc/nginx/sites-available/ct-api /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
sudo certbot --nginx -d api.example.com
```

## Systemd 서비스

```ini
# /etc/systemd/system/ct-backend.service
[Unit]
Description=CT System Backend
After=network.target

[Service]
User=ubuntu
WorkingDirectory=/opt/ct-system/backend
ExecStart=/usr/bin/java -jar -Xmx512m -Xms256m target/ct-backend.jar --spring.profiles.active=production
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

```bash
sudo systemctl daemon-reload
sudo systemctl enable ct-backend
sudo systemctl start ct-backend
```
