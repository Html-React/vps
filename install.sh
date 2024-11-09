#!/bin/bash

read -p "Установить русский пакет и времянную зону Самара (y/n): " INSTALL_A
INSTALL_A=${INSTALL_A:-y}  # Устанавливаем значение по умолчанию "y"

if [[ "$INSTALL_A" =~ ^[yY]$ ]]; then
	apt install -y language-pack-ru language-pack-ru-base locales
	locale-gen en_US.UTF-8
	update-locale LANG=en_US.UTF-8
	timedatectl set-timezone Europe/Samara
fi

read -p "Установить Python? (y/n): " INSTALL_B
INSTALL_B=${INSTALL_B:-y}  # Устанавливаем значение по умолчанию "y"

if [[ "$INSTALL_B" =~ ^[yY]$ ]]; then
	bash <(curl -Ls https://raw.githubusercontent.com/Html-React/vps/refs/heads/main/install_python.sh)
fi

read -p "Установить Teamspeak3? (y/n): " INSTALL_C
INSTALL_C=${INSTALL_C:-y}  # Устанавливаем значение по умолчанию "y"

if [[ "$INSTALL_C" =~ ^[yY]$ ]]; then
	apt-get update
	apt-get install -y wget
	bash <(curl -Ls https://raw.githubusercontent.com/Html-React/vps/refs/heads/main/install_teamspeak3_server.sh)
fi

read -p "Установить OpenVpn? (y/n): " INSTALL_D
INSTALL_D=${INSTALL_D:-y}  # Устанавливаем значение по умолчанию "y"

if [[ "$INSTALL_D" =~ ^[yY]$ ]]; then
	bash <(curl -Ls https://raw.githubusercontent.com/Html-React/vps/refs/heads/main/openvpn-install.sh)
fi

read -p "Cгенерировать сертивфикат на все вопросы Enter? (y/n): " INSTALL_E
INSTALL_E=${INSTALL_E:-y}  # Устанавливаем значение по умолчанию "y"

if [[ "$INSTALL_E" =~ ^[yY]$ ]]; then
	openssl req -x509 -keyout /etc/ssl/certs/3x-ui.key -out /etc/ssl/certs/3x-ui.pem -newkey rsa:4096 -sha256 -days 3650 -nodes -new
fi

read -p "Установить 3x-UI-Web Panel? (y/n): " INSTALL_F
INSTALL_F=${INSTALL_F:-y}  # Устанавливаем значение по умолчанию "y"

if [[ "$INSTALL_F" =~ ^[yY]$ ]]; then
	bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh)
fi



