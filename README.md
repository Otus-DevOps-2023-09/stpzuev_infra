# stpzuev_infra
stpzuev Infra repository

## Home Work 3, SSH Proxy Jump:
### Первый способ правильный, использовать опцию "-J"
```
ssh -J appuser@84.252.130.233 appuser@10.128.0.21
```
### Второй способ с костылями
```
ssh -A -t appuser@84.252.130.233 ssh appuser@10.128.0.21
```
Запускаем удаленно ssh подключение, "-A" использует ssh агента, "-t" запускает команду на псевдо-терминале.

### Бонус трек. SSH Config Alias
Добавляем настройки для бастиона и локальных машин в **~/.ssh/config**
```
Host bastion
  user appuser
  IdentityFile ~/.ssh/appuser
  hostname 35.198.167.169

Host someinternalhost
  IdentityFile ~/.ssh/appuser
  hostname 10.156.0.3
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
