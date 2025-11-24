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
./configure \
--sbin-path=/usr/sbin/nginx \
--conf-path=/etc/nginx/nginx.conf \
--error-log-path=/var/log/nginx/error.log \
--http-log-path=/var/log/nginx/access.log \
--pid-path=/run/nginx.pid \
--lock-path=/var/lock/nginx.lock \
--with-threads \
--with-file-aio \
--with-compat \
--with-pcre \
--with-pcre-jit \
--with-http_ssl_module \
--with-http_v2_module \
--with-http_v3_module \
--with-http_stub_status_module \
--with-http_gzip_static_module \
--with-http_realip_module \
--with-http_limit_conn_module \
--with-http_limit_req_module && \
make && make install && \
mkdir -p /etc/nginx/conf.d && \
echo "OK — nginx 1.29.3 установлен из исходников"

nginx -v
nginx -t

systemctl stop nginx 2>/dev/null
nginx
```
### Справка Базовые must-have
```
# Эти нужны почти всегда:
--with-http_ssl_module          # HTTPS
--with-http_v2_module           # HTTP/2
--with-http_v3_module           # HTTP/3 + QUIC
--with-threads                  # многопоточность, ускоряет IO
--with-file-aio                 # ускоряет работу с файлами
--with-pcre                     # нормальная обработка регулярных выражений
--with-pcre-jit                 # JIT ускоряет regex в 3–5 раз
--with-compat                   # совместимость для динамических модулей

# Полезные, безопасные, не создают проблем:
--with-http_stub_status_module  # статистика /status
--with-http_realip_module       # если стоишь за Cloudflare / Nginx Proxy
--with-http_gzip_static_module  # статика *.gz
--with-http_sub_module          # подмены в теле ответа

Если нужен rate-limit и защита от DDoS:
--with-http_limit_conn_module
--with-http_limit_req_module

Если сервер отдаёт большие файлы:
--with-file-aio
--with-threads
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

## Ниже полный bash-скрипт (готов к запуску от root на Ubuntu 24.04) который:

- удаляет пакеты nginx из apt (чтобы не было конфликтов),

- устанавливает все зависимости (включая Rust/Cargo для nginx-acme-module),

- скачивает и собирает OpenSSL (версию ≥ 3.5.1 рекомендовано для QUIC/HTTP/3 — иначе используем слой совместимости), nginx.org,

- скачивает и собирает nginx 1.29.3 со включёнными http_v2 и http_v3 (HTTP/3/QUIC), ssl, pcre, threads, file-aio, compat и т.д.; подключает OpenSSL собранный локально,

- подключает и собирает nginx-acme-module как динамический модуль (или компилирует модуль отдельно и копирует),

- создаёт нужные каталоги (/var/www, /var/lib/nginx/acme), проверяет/создаёт пользователя www-data и выставляет права,

- ставит systemd unit и запускает сервис.

- Перед запуском: внимательно прочитайте скрипт. HTTP/3 требует либо OpenSSL с поддержкой QUIC (рекомендуется 3.5.1+)

  !!!!!!!!!!!!!!!!!!!! Скрипт нужно править сборка модуля не отработает ngx_http_acme_module !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!1
```
#!/usr/bin/env bash
set -euo pipefail

NGINX_VER="1.29.3"
OPENSSL_VER="openssl-3.5.1"   # рекомендуемая минимальная версия для QUIC (можно изменить)
OPENSSL_TARBALL="openssl-3.5.1.tar.gz"
WORKDIR="/usr/local/src"
NGINX_SRC_DIR="${WORKDIR}/nginx-${NGINX_VER}"
NGINX_ACME_REPO="https://github.com/nginx-modules/ngx_http_acme_module.git"
NGINX_ACME_DIR="${WORKDIR}/nginx-acme-module"
MAKE_JOBS=$(nproc)

echo "1) Остановка и удаление apt-пакетов nginx (если есть)"
systemctl stop nginx >/dev/null 2>&1 || true
apt remove --purge -y nginx nginx-common nginx-core nginx-full || true
apt autoremove -y

echo "2) Установка зависимостей для сборки (компилятор, dev-библиотеки, rust/cargo и т.д.)"
apt update
DEPS="build-essential ca-certificates curl git cmake pkg-config libpcre3 libpcre3-dev zlib1g zlib1g-dev libssl-dev libcurl4-openssl-dev libjansson-dev ca-certificates nasm"
# Rust / cargo for the acme module (if not installed, install via rustup)
apt install -y $DEPS curl

# Install rustup if cargo not present
if ! command -v cargo >/dev/null 2>&1; then
  echo "Installing Rust toolchain (rustup)..."
  curl https://sh.rustup.rs -sSf | sh -s -- -y
  export PATH="$HOME/.cargo/bin:$PATH"
fi

echo "3) Создаём рабочие каталоги"
mkdir -p "$WORKDIR"
cd "$WORKDIR"

echo "4) Скачиваем исходники nginx и nginx-acme-module"
if [ ! -d "$NGINX_SRC_DIR" ]; then
  wget -c "https://nginx.org/download/nginx-${NGINX_VER}.tar.gz"
  tar xzf "nginx-${NGINX_VER}.tar.gz"
fi

if [ ! -d "$NGINX_ACME_DIR" ]; then
  git clone --depth=1 "$NGINX_ACME_REPO" "$NGINX_ACME_DIR"
fi

echo "5) Загружаем и собираем OpenSSL ${OPENSSL_VER} локально (для QUIC/HTTP3 рекомендуется >=3.5.1)"
cd "$WORKDIR"
if [ ! -f "${OPENSSL_TARBALL}" ]; then
  wget -c "https://www.openssl.org/source/${OPENSSL_TARBALL}"
fi

if [ ! -d "${WORKDIR}/${OPENSSL_VER}" ]; then
  tar xzf "${OPENSSL_TARBALL}"
fi

# Сборка OpenSSL
cd "${WORKDIR}/${OPENSSL_VER}"
./config no-shared --prefix="${WORKDIR}/${OPENSSL_VER}-build" --openssldir="${WORKDIR}/${OPENSSL_VER}-build"
make -j"$MAKE_JOBS"
make install_sw

OPENSSL_BUILD_DIR="${WORKDIR}/${OPENSSL_VER}-build"

echo "6) Конфигурация nginx с http2 и http3 и подключением локального OpenSSL"
cd "$NGINX_SRC_DIR"

# Опции, которые вы указали и рекомендуем дополнительно
CONFIG_FLAGS=(
  "--sbin-path=/usr/sbin/nginx"
  "--conf-path=/etc/nginx/nginx.conf"
  "--error-log-path=/var/log/nginx/error.log"
  "--http-log-path=/var/log/nginx/access.log"
  "--with-http_ssl_module"
  "--with-http_v2_module"
  "--with-http_v3_module"
  "--with-threads"
  "--with-file-aio"
  "--with-compat"
  "--with-pcre"
  "--with-http_realip_module"
  "--with-http_gzip_static_module"
  "--with-http_stub_status_module"
  "--with-stream"
  "--with-stream_ssl_module"
  "--with-cc-opt='-O2 -g'"
  "--with-ld-opt='-Wl,-Bsymbolic-functions -Wl,-z,relro -Wl,-z,now'"
  "--with-openssl=${OPENSSL_BUILD_DIR}/.."
)

# Note: --with-openssl expects path to the OpenSSL source directory; we put openssl source in WORKDIR/openssl-3.5.1
# ensure the source directory name matches OPENSSL_VER variable above (openssl-3.5.1)
./configure "${CONFIG_FLAGS[@]}" --add-dynamic-module="${NGINX_ACME_DIR}"
# если ./configure падает — читаем ошибку и правим зависимости

echo "7) Сборка nginx"
make -j"$MAKE_JOBS"

echo "8) Установка (перезапишет /usr/sbin/nginx установленный ранее)"
make install

echo "9) Сборка и установка динамического модуля ACME (если не был собран как --add-dynamic-module)"
# Если модуль уже собрался как динамический модуль он будет в objs/ и будет установлен вместе с make install.
# Но на всякий случай соберём модуль отдельно и скопируем в /usr/lib/nginx/modules
cd "$NGINX_SRC_DIR"
make modules || true
if [ -f objs/ngx_http_acme_module.so ]; then
  cp -v objs/ngx_http_acme_module.so /usr/lib/nginx/modules/
fi

echo "10) Создаём нужные каталоги и права"
mkdir -p /var/www
mkdir -p /var/lib/nginx/acme
# Проверяем наличие пользователя www-data, создаём если нужно
if ! id -u www-data >/dev/null 2>&1; then
  useradd -r -s /usr/sbin/nologin -d /var/www www-data
fi
chown -R www-data:www-data /var/www
chown -R www-data:www-data /var/lib/nginx
chmod 750 /var/lib/nginx/acme

echo "11) Устанавливаем systemd unit (если нужен)"
cat >/etc/systemd/system/nginx.service <<'SYSTEMD_EOF'
[Unit]
Description=nginx - high performance web server
After=network.target remote-fs.target nss-lookup.target

[Service]
Type=forking
PIDFile=/run/nginx.pid
ExecStartPre=/usr/sbin/nginx -t -q
ExecStart=/usr/sbin/nginx
ExecReload=/usr/sbin/nginx -s reload
ExecStop=/usr/sbin/nginx -s quit
PrivateTmp=true

[Install]
WantedBy=multi-user.target
SYSTEMD_EOF

systemctl daemon-reload
systemctl enable nginx

echo "12) Тест конфигурации nginx и запуск"
nginx -t
systemctl start nginx
systemctl status --no-pager nginx

echo "Готово. Проверьте nginx -v и nginx -V, а также логи при ошибках."
echo "nginx -v:"
nginx -v || true
echo "nginx -V:"
nginx -V || true
```
### Скопируй весь этот текст в файл:
```
install-nginx.sh
```
### и запусти:
```
bash install-nginx.sh
```
