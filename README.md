# Разварачиваем на VPS/VDS:
- Python
- Teamspeak3
- OpenVpn
- 3x-UI-Web Panel

## Для запуска
```code
  bash <(curl -Ls https://raw.githubusercontent.com/Html-React/vps/refs/heads/main/install.sh)
```

```python
from Crypto.Cipher import AES
from Crypto.Util.Padding import pad, unpad
from Crypto.Random import get_random_bytes
import base64


def encrypt(data, key):
    # Генерация случайного инициализационного вектора (IV)
    iv = get_random_bytes(AES.block_size)

    # Создание объекта шифратора AES с ключом и IV
    cipher = AES.new(key, AES.MODE_CBC, iv)

    # Дополнение данных до кратности блоку AES
    padded_data = pad(data.encode(), AES.block_size)

    # Шифрование данных
    encrypted_data = cipher.encrypt(padded_data)

    # Возвращаем зашифрованные данные и IV (обе части понадобятся для расшифровки)
    return base64.b64encode(iv + encrypted_data).decode()


def decrypt(encrypted_data, key):
    # Декодирование зашифрованных данных из base64
    encrypted_data = base64.b64decode(encrypted_data)

    # Извлечение IV и зашифрованных данных
    iv = encrypted_data[:AES.block_size]
    encrypted_data = encrypted_data[AES.block_size:]

    # Создание объекта расшифровщика AES с ключом и IV
    cipher = AES.new(key, AES.MODE_CBC, iv)

    # Расшифровка данных и удаление дополнений
    decrypted_data = unpad(cipher.decrypt(encrypted_data), AES.block_size)

    # Возвращаем расшифрованные данные в виде строки
    return decrypted_data.decode()


def main():

    # Пример ключа (256 бит), который будет использоваться для шифрования
    key = get_random_bytes(32)  # 32 байта = 256 бит
    print("ключ шифрования: ", key)
    # Пример текста, который нужно зашифровать
    data = "Люблю пить молоко и кушать печеньки"

    print("Исходные данные:", data)

    # Шифруем данные
    encrypted_data = encrypt(data, key)
    print("Зашифрованные данные:", encrypted_data)

    # Расшифровываем данные
    decrypted_data = decrypt(encrypted_data, key)
    print("Расшифрованные данные:", decrypted_data)


if name == "main":
    main()
```
