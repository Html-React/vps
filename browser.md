## 🦊 Firefox
### about:config → выставь точно так:
```
media.peerconnection.enabled = true
media.peerconnection.ice.proxy_only = true
media.peerconnection.ice.default_address_only = true
media.peerconnection.ice.no_host = true
media.peerconnection.ice.no_mdns = false
```

#### Почему это работает
#### proxy_only → WebRTC не обходит прокси
#### default_address_only → не перебирает интерфейсы
#### no_host → не показывает локальные IP
#### mdns → скрывает LAN



## 🌐 Chromium / Chrome / Brave
### chrome://flags
```
Включи:
WebRTC IP Handling Policy → Disable non-proxied UDP
Если есть:
Anonymize local IPs exposed by WebRTC → ENABLE
```
