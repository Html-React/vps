#!/bin/bash

# Запрос версии Python у пользователя
read -p "Enter the version of Python you want to install (for example, 3.10): " PYTHON_VERSION
PYTHON_VERSION=${PYTHON_VERSION:-3.10}

# Установка необходимых зависимостей
sudo apt install -y software-properties-common

# Обновите все имеющиеся ПО
sudo apt-get update -y && sudo apt upgrade -y

# Включите в список системных репозиториев еще один репозиторий для Python
sudo add-apt-repository -y ppa:deadsnakes/ppa
sudo apt update -y

# Получаем список доступных версий Python
AVAILABLE_VERSIONS=$(apt-cache show python3 | grep -oP 'Version: \K[0-9]+\.[0-9]+')

# Проверяем, существует ли введенная версия
if echo "$AVAILABLE_VERSIONS" | grep -q "$PYTHON_VERSION"; then
    echo "Version $PYTHON_VERSION is available. Installing..."
    sudo apt-get install -y python$PYTHON_VERSION python$PYTHON_VERSION-venv python$PYTHON_VERSION-pip
else
    echo "Version $PYTHON_VERSION not found. Installing the latest available version..."
    LATEST_VERSION=$(echo "$AVAILABLE_VERSIONS" | sort -V | tail -n 1)
    echo "Latest version is $LATEST_VERSION. Installing..."
    sudo apt-get install -y python$LATEST_VERSION python$LATEST_VERSION-venv python$LATEST_VERSION-pip
    PYTHON_VERSION=$LATEST_VERSION
fi

# Добавление Python версии в update-alternatives, если она еще не добавлена
sudo update-alternatives --install /usr/bin/python python /usr/bin/python$PYTHON_VERSION 1

# Настроим приоритет для python
sudo update-alternatives --config python

