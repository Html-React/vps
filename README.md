# Разворачиваем на VPS/VDS:
- Python
- Teamspeak3
- OpenVpn
- 3x-UI-Web Panel

## Для запуска
```code
  bash <(curl -Ls https://raw.githubusercontent.com/Html-React/vps/refs/heads/main/install.sh)
```

Certbot
Чтобы установить и использовать Certbot:

```code
apt-get install certbot -y
certbot certonly --standalone --agree-tos --register-unsafely-without-email -d yourdomain.com
certbot renew --dry-run

```
