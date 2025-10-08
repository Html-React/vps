# Сборка модуля libnginx_acme.so для Nginx

Этот гайд показывает, как пересобрать модуль `libnginx_acme.so` под текущую версию Nginx, чтобы избежать ошибок несовпадения версий.

---

## 1. Подготовка системы

Установите необходимые зависимости:

```bash
apt update
apt install -y pkg-config clang libclang-dev build-essential libpcre3 libpcre3-dev zlib1g-dev libssl-dev wget tar curl
# Установка cargo — менеджер сборки Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
# После установки, добавьте cargo в PATH:
source $HOME/.cargo/env
cargo --version
rustc --version
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
# Сборка модуля
cd /usr/local/src/nginx-1.29.2
./configure --with-compat --add-dynamic-module=/usr/local/src/nginx-acme-module/ --with-http_ssl_module
make clean
make modules
cp objs/ngx_modules/ngx_http_acme_module.so /usr/local/nginx/modules/

# Проверка конфигурации nginx
sudo nginx -t

# Перезапуск nginx
sudo systemctl restart nginx
sudo systemctl status nginx
```
