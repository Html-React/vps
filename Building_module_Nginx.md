# Сборка модуля libnginx_acme.so для Nginx

Этот гайд показывает, как пересобрать модуль `libnginx_acme.so` под текущую версию Nginx, чтобы избежать ошибок несовпадения версий.

---

## 1. Подготовка системы

Установите необходимые зависимости:

```bash
apt update
apt install -y pkg-config clang libclang-dev build-essential libpcre3 libpcre3-dev zlib1g-dev libssl-dev wget tar curl
# Установка cargo — менеджер сборки Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh # нажать enter
# После установки, добавьте cargo в PATH:
source $HOME/.cargo/env
cargo --version
rustc --version
mkdir -p /var/lib/nginx/acme
chown -R www-data:www-data /var/lib/nginx
chmod 750 /var/lib/nginx/acme
```

## 1.1 Установить последний nginx 1.29.3 
Импортируем ключ:
```
apt update

apt purge -y nginx nginx-core nginx-common nginx-full && \
rm -rf /etc/nginx /usr/sbin/nginx /usr/lib/nginx && \
apt update && \
apt install -y build-essential libpcre3 libpcre3-dev zlib1g-dev libssl-dev && \
cd /usr/local/src && \
wget https://nginx.org/download/nginx-1.29.3.tar.gz && \
tar xzf nginx-1.29.3.tar.gz && \
cd nginx-1.29.3 && \
./configure --sbin-path=/usr/sbin/nginx \
            --conf-path=/etc/nginx/nginx.conf \
            --error-log-path=/var/log/nginx/error.log \
            --http-log-path=/var/log/nginx/access.log \
            --with-http_ssl_module \
            --with-http_v2_module \
            --with-pcre && \
make && make install && \
mkdir -p /etc/nginx/conf.d && \
echo "OK — nginx 1.29.3 установлен из исходников"

nginx -v
nginx -t

systemctl stop nginx 2>/dev/null
nginx
```

## Создай сервис-файл
```
cat >/etc/systemd/system/nginx.service <<'EOF'
[Unit]
Description=nginx - high performance web server
After=network.target
Wants=network.target

[Service]
Type=forking
PIDFile=/run/nginx.pid
ExecStart=/usr/sbin/nginx
ExecReload=/usr/sbin/nginx -s reload
ExecStop=/usr/sbin/nginx -s quit
Restart=always

# Create PID directory if missing
ExecStartPre=/bin/mkdir -p /run
ExecStartPre=/bin/mkdir -p /run/nginx
ExecStartPre=/bin/chown www-data:www-data /run/nginx

User=www-data
Group=www-data

[Install]
WantedBy=multi-user.target
EOF
```
```
systemctl daemon-reload
systemctl enable nginx
systemctl start nginx
systemctl status nginx
```
Убедись, что в /etc/nginx/nginx.conf указано: user  www-data;

## 2. Скачать исходники Nginx

Скачайте исходники версии Nginx, под которую нужно собрать модуль.
Замените 1.29.2 на вашу текущую версию:

```
cd /usr/local/src
wget https://nginx.org/download/nginx-1.29.3.tar.gz
tar zxvf nginx-1.29.3.tar.gz
```

## 3. Сборка модуля ACME (готовый блок команд)

Скачать исходник модуля
https://github.com/nginx/nginx-acme
```
cd /usr/local/src
mkdir -p nginx-acme-module
wget https://github.com/nginx/nginx-acme/releases/download/v0.3.0/nginx-acme-0.3.0.tar.gz # новая версия
tar -xzvf nginx-acme-0.3.0.tar.gz -C nginx-acme-module --strip-components=1
```
Теперь исходники модуля находятся в /usr/local/src/nginx-acme-module.

```
# Сборка модуля
cd /usr/local/src/nginx-1.29.3
# Отчистка от старых версий
make clean 
./configure --with-compat --add-dynamic-module=/usr/local/src/nginx-acme-module/ --with-http_ssl_module
make modules
# Если make modules не запуститься то просто
make
cp objs/ngx_http_acme_module.so /usr/lib/nginx/modules/

# Проверка конфигурации nginx
sudo nginx -t

# Перезапуск nginx
sudo systemctl restart nginx
sudo systemctl status nginx
```
## Создание папкт www
```
mkdir -p /var/www
chown -R www-data:www-data /var/www
chmod 755 /var/www
```

## Дополнительно
Если systemctl status nginx выдает ошибку "nginx.service: Can't open PID file /run/nginx.pid (yet?) after start: Operation not permitted"
```
# Добавить строку в /usr/lib/systemd/system/nginx.service
[Service]
ExecStartPost=/bin/sleep 1
```
