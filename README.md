# stpzuev_infra
stpzuev Infra repository

## Home Work 3, SSH Proxy Jump:
### Данные для подключения к YC
```
bastion_IP = 158.160.41.35
someinternalhost_IP = 10.128.0.21
```

### Первый способ правильный, использовать опцию "-J"
```
ssh -J appuser@158.160.41.35 appuser@10.128.0.21
```
### Второй способ с костылями
```
ssh -A -t appuser@158.160.41.35 ssh appuser@10.128.0.21
```
Запускаем удаленно ssh подключение, "-A" использует ssh агента, "-t" запускает команду на псевдо-терминале.

### Бонус трек. SSH Config Alias
Добавляем настройки для бастиона и локальных машин в **~/.ssh/config**
```
Host bastion
  user appuser
  IdentityFile ~/.ssh/appuser
  hostname 158.160.41.35

Host someinternalhost
  IdentityFile ~/.ssh/appuser
  hostname 10.128.0.21
  user appuser
  proxyjump gateway
```
Подключаемся к бастиону
```
ssh bastion
```
Подключаемся к локальной машине
```
ssh someinternalhost
```

## Pritunl Bastion Lets Encrypt
В веб интерфейсе Pritunl нажимаем Settings, выбираем Lets Encrypt Domain и прописываем **"<наш ip-адрес>.nip.io"**
Сохраняем. Перезагружем страницу и все работает.
https://158.160.41.35.nip.io
