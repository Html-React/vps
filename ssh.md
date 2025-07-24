## Создаем SSH

- Проверка
```
sudo systemctl status ssh
```
- Если SSH не установлен, установите его:
```
sudo apt update
sudo apt install openssh-server
sudo systemctl enable ssh
sudo systemctl start ssh
```
- (Опционально) Настройка подключения по SSH-ключу
- На локальной машине создайте ключ (если еще не сделали):
#### Пример с именем ключа test
```
ssh-keygen -t rsa -b 4096 -f ~/.ssh/test
```
- Теперь можно подключаться без ввода пароля:
```
ssh -i ~/.ssh/test user@your.server.ip
```
#### Пример без имени создаст файлы:
-  id_rsa	🔒 Приватный ключ — храните его в секрете!
-  d_rsa.pub	🔓 Публичный ключ — можно копировать на сервер
```
ssh-keygen -t rsa -b 4096
```
- Отправьте ключ на сервер:
```
ssh-copy-id username@ip-сервера
```
- Теперь можно подключаться без ввода пароля:
```
ssh username@ip-сервера
```

## Добавлению публичного ключа вручную
- Создайте ключ
- Скопируй содержимое публичного ключа
```
cat ~/.ssh/id_rsa.pub
```
- Подключись к серверу
- Создай папку .ssh на сервере, если её нет
```
mkdir -p ~/.ssh
chmod 700 ~/.ssh
```
- Добавь публичный ключ в файл authorized_keys
```
nano ~/.ssh/authorized_keys
```
- Установи нужные права:
```
chmod 600 ~/.ssh/authorized_keys
```
- Проверь, что SSH разрешает вход по ключу
- Файл конфигурации: /etc/ssh/sshd_config
- Убедись, что там есть (или раскомментировано):
```
PubkeyAuthentication yes
AuthorizedKeysFile .ssh/authorized_keys
```
- После изменений перезапусти SSH:
```
sudo systemctl restart ssh
```

