#!/bin/bash


# Установка необходимых зависимостей
apt install -y software-properties-common

# Обновите все имеющиеся ПО
apt-get update -y && apt upgrade -y

# Включите в список системных репозиториев еще один репозиторий для Python
add-apt-repository -y ppa:deadsnakes/ppa
apt update -y	

# Получаем список доступных версий Python
AVAILABLE_VERSIONS=$(apt-cache search python3.1 | grep -oP 'python3\.\d{2}' | sed 's/python3\./3./' | sort -u)
apt-cache search python3.1
# Выводим список доступных версий
echo "Доступные версии Python:"
echo "$AVAILABLE_VERSIONS"

# Запрос версии Python у пользователя
read -p "Enter the version of Python you want to install (for example, 3.10): " PYTHON_VERSION
PYTHON_VERSION=${PYTHON_VERSION:-3.10}

# Проверяем, существует ли введенная версия
if echo "$AVAILABLE_VERSIONS" | grep -q "$PYTHON_VERSION"; then
	echo "Version $PYTHON_VERSION is available. Installing..."
	apt-get install -y python$PYTHON_VERSION python$PYTHON_VERSION-venv python3-pip	
	
else
	echo "Version $PYTHON_VERSION not found. Installing the latest available version..."
	LATEST_VERSION=$(echo "$AVAILABLE_VERSIONS" | sort -V | tail -n 1)
	echo "Latest version is $LATEST_VERSION. Installing..."
	apt-get install -y python$LATEST_VERSION python$LATEST_VERSION-venv python3-pip
	PYTHON_VERSION=$LATEST_VERSION
fi

# Добавление Python версии в update-alternatives, если она еще не добавлена
update-alternatives --install /usr/bin/python python /usr/bin/python$PYTHON_VERSION 1

# Настроим приоритет для python
update-alternatives --set python /usr/bin/python$PYTHON_VERSION


