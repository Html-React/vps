# Сборка модуля libnginx_acme.so для Nginx

Этот гайд показывает, как пересобрать модуль `libnginx_acme.so` под текущую версию Nginx, чтобы избежать ошибок несовпадения версий.

---

## 1. Подготовка системы

Установите необходимые зависимости:

```bash
sudo apt update
sudo apt install -y build-essential libpcre3 libpcre3-dev zlib1g-dev libssl-dev wget
```

## 2. Скачать исходники Nginx

Скачайте исходники версии Nginx, под которую нужно собрать модуль.
Замените 1.29.2 на вашу текущую версию:

```
cd /usr/local/src
wget http://nginx.org/download/nginx-1.29.2.tar.gz
tar zxvf nginx-1.29.2.tar.gz
```

## 3. Сборка модуля ACME (готовый блок команд)

Скачать исходник модуля
https://github.com/nginx/nginx-acme
```
cd /usr/local/src
mkdir -p nginx-acme-module
wget http://github.com/nginx/nginx-acme/releases/download/v0.1.1/nginx-acme-0.1.1.tar.gz
tar -xzvf nginx-acme-0.1.1.tar.gz -C nginx-acme-module --strip-components=1
```
Теперь исходники модуля находятся в /usr/local/src/nginx-acme-module.

```
# Путь к исходникам модуля
ACME_MODULE_DIR=/usr/local/src/nginx-acme-module

# Путь к исходникам Nginx
NGINX_SRC_DIR=/usr/local/src/nginx-1.29.2

# Сборка модуля
cd $ACME_MODULE_DIR
make clean
$NGINX_SRC_DIR/configure --with-compat --add-dynamic-module=$ACME_MODULE_DIR
make
sudo make install

# Проверка конфигурации nginx
sudo nginx -t

# Перезапуск nginx
sudo systemctl restart nginx
sudo systemctl status nginx
```
