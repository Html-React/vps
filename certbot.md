# Получение сертификата

## Получение и настройка (с автонастройкой nginx или apache)
```
sudo certbot --nginx -d example.com
sudo certbot --apache -d example.com

# Только получить (без автонастройки)
sudo certbot certonly --nginx -d example.com
sudo certbot certonly --standalone -d example.com
sudo certbot certonly --manual -d example.com
```
## Команда для автоматического запроса сертификата через nginx:
```
certbot certonly --nginx -d test.devkul.space --non-interactive --agree-tos --force-renewal -m your-email@example.com

```
certonly - запрашивает только сертификат — не настраивает автоматом HTTPS в nginx (хотя и использует его для валидации).

--nginx - Использует Nginx-плагин Certbot'а для автоматической проверки домена и управления валидацией (через HTTP-01 challenge).

-d test.devkul.space - Домен, для которого нужен сертификат. Можно указывать несколько -d (для поддоменов).

--non-interactive — отключает все запросы к пользователю.

--agree-tos — автоматически принимает условия обслуживания Let's Encrypt.

--force-renewal — принудительно обновляет сертификат, даже если он ещё действителен.

-m your-email@example.com — обязательный адрес электронной почты (для уведомлений Let's Encrypt).
## Через DNS (API)
```
sudo certbot certonly --dns-cloudflare --dns-cloudflare-credentials /path/to/creds.ini -d example.com
```

# 🟨 🔄 Продление сертификатов

## Продлить все сертификаты, если нужно
```
sudo certbot renew
```
## Продлить и перезапустить службы (например nginx)
```
sudo certbot renew --deploy-hook "systemctl reload nginx"
```
## Проверка без продления (dry run)
```
sudo certbot renew --dry-run
```

# 🟧 🔧 Управление сертификатами

## Показать все установленные сертификаты
```
sudo certbot certificates
```
## Удалить сертификат
```
sudo certbot delete --cert-name example.com
```
## Повторно запустить получение с новым способом
```
sudo certbot certonly --force-renewal -d example.com
```

# 🟪 🧪 Тестирование и отладка

## Проверить доступность Certbot-сервера
```
sudo certbot --version
```

## Получить сертификат, но не сохранять (для тестов)
```
sudo certbot certonly --staging --standalone -d example.com
```

## Включить подробный вывод
```
sudo certbot --nginx -d example.com --debug-challenges --verbose
```

# 🟥 🔒 Автоматизация и хуки

## Хук при успешном обновлении
```
--deploy-hook "/usr/bin/systemctl reload nginx"
```

## Хук до обновления
```
--pre-hook "systemctl stop nginx"
```

## Хук после обновления
```
--post-hook "systemctl start nginx"
```
# Проверить работу автоматического обновления

## ✅ 1. Проверь cron или systemd таймер

### Certbot может быть установлен через:

   - cron (классическая периодическая задача)

   - systemd timer (современный способ на systemd-системах)

### 🔍 Проверка systemd (на большинстве современных дистрибутивов):
```
systemctl list-timers | grep certbot
```
Ожидаемый результат может выглядеть так:

Thu 2025-07-27 03:15:00 UTC  16h left    certbot.timer   certbot.service

Если строка есть — значит автоматическое обновление настроено через systemd.

### 🔧 Чтобы посмотреть содержимое:
```
systemctl status certbot.timer
```
### 🔍 Проверка cron:
```
crontab -l
```
### Или проверь системные cron-файлы:
```
cat /etc/cron.d/certbot
```
Обычно там будет что-то вроде:

0 */12 * * * root test -x /usr/bin/certbot && certbot renew --quiet

Это означает, что certbot renew запускается каждые 12 часов.

## ✅ 2. Проверь журнал обновлений

Certbot ведёт журнал всех попыток обновления.
```
sudo less /var/log/letsencrypt/letsencrypt.log
```
Или:
```
sudo zgrep "renew" /var/log/letsencrypt/*.log*
```
В логах ты увидишь:

    Было ли обновление

    Какие сертификаты были обработаны

    Были ли ошибки

## ✅ 3. Проверь, когда сертификат истекает
```
sudo certbot certificates
```
Пример вывода:

Certificate Name: test.devkul.space
    Domains: test.devkul.space
    Expiry Date: 2025-10-12 13:45:23+00:00 (VALID: 78 days)
    Certificate Path: /etc/letsencrypt/live/test.devkul.space/fullchain.pem
    Private Key Path: /etc/letsencrypt/live/test.devkul.space/privkey.pem

Если до истечения больше 30 дней — certbot renew пока не будет ничего делать, если не использовать --force-renewal.


# ✅ Примеры команд

### Получить сертификат через nginx
 ```
 sudo certbot --nginx -d example.com
```
### Только получить (не настраивать nginx)
 ```
 sudo certbot certonly --standalone -d example.com
```
### Получить через DNS Cloudflare
 ```
 sudo certbot certonly --dns-cloudflare --dns-cloudflare-credentials /root/cloudflare.ini -d example.com
```
### Автоматическое продление
 ```
 sudo certbot renew
```
### Удалить сертификат
 ```
 sudo certbot delete --cert-name example.com
```
