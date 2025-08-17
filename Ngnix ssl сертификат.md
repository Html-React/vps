# HTTPS-настройка для devkul.com с помощью Certbot и Nginx (Ubuntu)

Инструкция по установке SSL-сертификата от Let's Encrypt с помощью Certbot на сервере Ubuntu.

---

## 📋 Требования

Перед началом убедитесь, что:

- У вас есть **домен devkul.com** с доступом к DNS-записям
- DNS-записи A @ указывают на IP-адрес вашего сервера
- DNS-записи A www указывают на IP-адрес вашего сервера
- Установлен и настроен **Nginx**
- Порты **80** (HTTP) и **443** (HTTPS) открыты (`sudo ufw allow 'Nginx Full'`)

---

## 🛠️ Установка Certbot

### Обновите систему:
```bash
sudo apt update
sudo apt upgrade -y
```

### Установите Certbot и плагин для Nginx:
```bash
sudo apt install certbot python3-certbot-nginx -y
```

---

## 🔐 Получение и установка SSL-сертификата

### Запустите Certbot с параметрами для Nginx:
```bash
sudo certbot --nginx -d devkul.com -d www.devkul.com
```

Certbot:
- Подтвердит владение доменом
- Получит SSL-сертификат от Let's Encrypt
- Настроит HTTPS для Nginx
- Предложит включить редирект HTTP → HTTPS (выберите `2`)

---

## ✅ Проверка конфигурации

### Проверьте корректность конфигурации:
```bash
sudo nginx -t
```

### Перезапустите Nginx:
```bash
sudo systemctl reload nginx
```

---

## 🌍 Проверка HTTPS

```
openssl s_client -connect devkul.com:443 -servername devkul.space </dev/null | openssl x509 -noout -issuer -subject -dates
```
Вывод пример:
    depth=2 C = US, O = Internet Security Research Group, CN = ISRG Root X1
    verify return:1
    depth=1 C = US, O = Let's Encrypt, CN = E6
    verify return:1
    depth=0 CN = devkul.com
    verify return:1
    DONE
    issuer=C = US, O = Let's Encrypt, CN = E6
    subject=CN = devkul.space
    notBefore=Jul 19 17:05:26 2025 GMT
    notAfter=Oct 17 17:05:25 2025 GMT

Перейдите в браузере по адресам:
- https://devkul.com
- https://www.devkul.com

Проверьте наличие зелёного замка и сертификата от Let's Encrypt.

---

## 🔄 Автоматическое продление сертификата

### Проверка автоматизации (systemd):
```bash
sudo systemctl list-timers | grep certbot
```

### Ручная проверка продления:
```bash
sudo certbot renew --dry-run
```

Let's Encrypt сертификаты действуют 90 дней, Certbot настроен продлевать их автоматически.

---

## 📁 Где хранятся сертификаты

Файлы сертификатов:
```
/etc/letsencrypt/live/devkul.com/
```

---
## Файл конфиг
```
# HTTP > HTTPS
server {
    listen 80;
    listen [::]:80;
    server_name devkul.space www.devkul.space;
    return 301 https://$host$request_uri;
}

# Фоллбек от Xray (TCP без SSL!)
server {
    listen 10443 http2;
    listen [::]:10443 http2;
    server_name devkul.space www.devkul.space;

    root /var/www/dev;
    index index.html index.htm;

    # Важно! HSTS
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;

    # Защита скрытых файлов
    location ~ /\.(?!well-known).* {
        deny all;
    }

    location / {
        try_files $uri $uri/ =404;

        if ($request_uri ~ ^(.+)/+$) {
            return 301 $scheme://$host$1;
        }
    }

    error_page 404 /404.html;
    location = /404.html {
        internal;
    }

    access_log /var/log/nginx/devkul10443.access.log;
    error_log  /var/log/nginx/devkul10443.error.log;
}
```



## 📞 Поддержка

Если что-то пошло не так:
- Проверяйте логи: `/var/log/letsencrypt/`
- Перепроверьте DNS-записи
- Убедитесь, что порты 80 и 443 открыты

---
