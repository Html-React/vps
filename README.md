# Разворачиваем на VPS/VDS:
- Python
- Teamspeak3
- OpenVpn
- 3x-UI-Web Panel

## Для запуска
```code
  bash <(curl -Ls https://raw.githubusercontent.com/Html-React/vps/refs/heads/main/install.sh)
```

## Инструкции для получения ssl сертификата для домена

[Инструкция для Certbot](certbot.md)

[Инструкция для Ngnix](Ngnix%20ssl%20%D1%81%D0%B5%D1%80%D1%82%D0%B8%D1%84%D0%B8%D0%BA%D0%B0%D1%82.md)

[Инструкция для Apache](Apache%20ssl%20%D1%81%D0%B5%D1%80%D1%82%D0%B8%D1%84%D0%B8%D0%BA%D0%B0%D1%82.md)

## Создаем SSH

[Инструкция для SSH](ssh.md)

## Разворачиваем с помощью Ansible на VPS/VDS VPN: 3x-UI-Web Panel -> Nginx -> Сайт подложку -> Для конкретного домена с получением SSL сертификата

[Инструкция](ansible-install-vpn.md)
