# stpzuev_infra
stpzuev Infra repository

## Homework 4, Test Application Deploy and Run:

### Variables for Tests
```
testapp_IP = 35.198.167.169
testapp_port = 9292
```

### Git preps local
```
git checkout -b cloud-testapp
git mv cloud-bastion.ovpn ./VPN/
git mv setupvpn.sh ./VPN/
```

### Yandex Cloud CLI
```
yc compute instance create `
--name reddit-app `
--zone ru-central1-a `
--hostname reddit-app `
--memory=2 `
--platform=standard-v3 `
--cores=2 `
--core-fraction 50 `
--create-boot-disk image-folder-id=standard-images,image-family=ubuntu-1604-lts,size=8 `
--network-interface subnet-name=default-ru-central1-a,nat-ip-version=ipv4 `
--ssh-key C:\Users\stpzu\.ssh\appuser.pub
```
Проверяем подключение к хосту через ssh **yc-user@<ip-addr>**

### ENV Install

```
sudo apt update
sudo apt install -y ruby-full ruby-bundler build-essential
sudo apt install mongodb
sudo systemctl enable mongodb
sudo systemctl start mongodb
sudo systemctl status mongodb
```

### Application Deploy
```
sudo apt install -y git
git clone -b monolith https://github.com/express42/reddit.git
cd reddit && bundle install
puma -d
ps aux | grep puma
```

### Common Bash Scripts
```
git update-index --chmod=+x install_ruby.sh
git update-index --chmod=+x install_mongodb.sh
git update-index --chmod=+x deploy.sh
```

### Extra part

Bash Script for deploy

**metadata.yaml** собираем все в один скрипт и запускаем в CLI

```
yc compute instance create `
--name reddit-app2 `
--zone ru-central1-a `
--hostname reddit-app2 `
--memory=2 `
--platform=standard-v3 `
--cores=2 `
--core-fraction 50 `
--create-boot-disk image-folder-id=standard-images,image-family=ubuntu-1604-lts,size=8 `
--network-interface subnet-name=default-ru-central1-a,nat-ip-version=ipv4 `
--metadata-from-file user-data=metadata.yaml
```

## Homework 3, SSH Proxy Jump:
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
