# Настройка безопасного доступа на Ubuntu

Этот README.md описывает шаги по настройке безопасного доступа на Ubuntu сервере с запретом прямого входа root, использованием SSH по ключам, баннером при попытке root-входа и использованием sudo через администратора.

---

## 1. Создание пользователя с sudo

```bash
sudo adduser adminuser
sudo usermod -aG sudo adminuser
```
Проверка:
```bash
groups adminuser
```

---

## 2. Настройка SSH

Откройте конфигурацию SSH:
```bash
sudo nano /etc/ssh/sshd_config
```

Добавьте или измените следующие строки:
```
Port 22
PermitRootLogin no           # запрещаем root
PasswordAuthentication no    # запрещаем вход по паролю
ChallengeResponseAuthentication no
PubkeyAuthentication yes     # разрешаем только ключи
Banner /etc/ssh/root_banner.txt
```

Перезапустите SSH:
```bash
sudo systemctl restart ssh
```

---

## 3. Создание баннера при попытке root-входа

```bash
sudo nano /etc/ssh/root_banner.txt
```
Содержимое:
```
########################################################
#              Вход под root запрещён!               #
#  Используйте обычного пользователя с sudo.       #
########################################################
```

---

## 4. Ограничение локального доступа root (опционально)

```bash
sudo passwd -l root               # блокируем пароль root
sudo usermod -s /usr/sbin/nologin root  # запрещаем вход в shell
```

> Root доступен через `sudo` пользователя adminuser.

---

## 5. Настройка SSH-ключей для adminuser

На локальной машине:
```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
ssh-copy-id adminuser@server_ip
```
Проверка подключения:
```bash
ssh adminuser@server_ip
```

Вход должен происходить **только по ключу**, без пароля.

---

## 6. Проверка безопасности

- Попытка входа под root:
```bash
ssh root@server_ip
```
→ должно показать баннер и отказ в доступе.

- Под adminuser с ключом — вход работает, команды с `sudo` доступны:
```bash
sudo apt update
```

---

✅ Сервер теперь настроен безопасно:
- Root не входит напрямую.
- Доступ только через пользователя с sudo.
- SSH работает только по ключам.
- Есть предупреждение при попытке root-входа.

