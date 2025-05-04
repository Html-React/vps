# HTTPS-настройка для devkul.com с помощью Certbot и Nginx (Ubuntu)

Инструкция по установке SSL-сертификата от Let's Encrypt с помощью Certbot на сервере Ubuntu.

---

## 📋 Требования

Перед началом убедитесь, что:

- У вас есть **домен devkul.com** с доступом к DNS-записям
- DNS-записи A указывают на IP-адрес вашего сервера
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

## 📞 Поддержка

Если что-то пошло не так:
- Проверяйте логи: `/var/log/letsencrypt/`
- Перепроверьте DNS-записи
- Убедитесь, что порты 80 и 443 открыты

---
