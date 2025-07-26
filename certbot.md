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
