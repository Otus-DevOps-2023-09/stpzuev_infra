# stpzuev_infra
Stepan Zuev Infra repository for educational purposes

# Homework 7, Terraform 2

## Main Part

### Clean project before

### Packer new images

Bake!
```shell
packer build -var-file="variables.json" app.json
packer build -var-file="variables.json" db.json
```
Done!

### Split main.tf
```
        /  -  app.tf
main.tf
        \  -  db.tf
        \  -  vpc.tf
```

New variables in **variables.tf**

New file **vpc.tf** and edit **main.tf**

Edit **outputs.tf**

#### Boot images
[Terraform yandex images Doc](https://terraform-provider.yandexcloud.net/Resources/compute_image)

### VPC

Quota for networks = 2 by default in Yandex. Can be upgraded in WebUI.

Apply everything. Done.

### !!! Question !!! Можно ли автоматически получать id образов своих сборок по `source_family`?

### Modules

Copy paste
```
terraform get
terraform apply
```
SSH test. Done

### Stage & Prod

Copy. Paste. Edit both main.tf
```
terraform init
terraform apply
terraform destroy
terraform fmt
```

## Bonus Part

### backend.tf

Create bucket [YC Doc Bucket](https://cloud.yandex.ru/docs/storage/operations/buckets/create)

```shell
yc storage bucket create --help

yc storage bucket create `
--name "stpzuev-app-backend" `
--default-storage-class cold
```

Плохой вариант. Лучше создать бакет в терраформ. Создадим в корне проекта bucket.tf
```
...
resource "yandex_storage_bucket" "terraform-storage" {
  bucket        = var.bucket_name
  access_key    = var.access_key
  secret_key    = var.secret_key
  force_destroy = "true"
}
```

Create config [YC Terraform State Storage](https://cloud.yandex.ru/docs/tutorials/infrastructure-management/terraform-state-storage)

[Terraform backend bucket](https://developer.hashicorp.com/terraform/language/settings/backends/s3)

Create backend.tf at /stage
```
terraform init
>> The parameter "endpoint" is deprecated. Use parameter "endpoints.s3" instead.

```

Здесь было потрачено очень много времени на поиск решения в глючном Terraform 1.6.3. Пришлось откатиться до 1.5.7 и **"О ЧУДО!"** все заработало по инструкции.

Создаем бакет. Создаем статический ключ через веб. Копируем значения.

```
$Env:ACCESS_KEY="key value"
$Env:SECRET_KEY="key value"
terraform init -backend-config="access_key=$env:ACCESS_KEY" -backend-config="secret_key=$env:SECRET_KEY"
```

Удаляем **terraform.tfstate** делаем apply. Копируем папку в новое место делаем init + apply. Все раеботает.

## Bonus part 2

Копируем **deploy.sh** в модуль app. Добавляем provision с сервисом puma в main.tf. Но нам нужно передать адрес инстанса DB в передаваемый сервис.

Переделаем **puma.service** в темплейт **puma.tpl** [Terraform Template](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file)

Добавляем переменную db_ip_address и передаем ее в модуль app. Запускаем puma.service.

Запускаем проект. Все работает.

---
# Homework 6, Terraform 1

[OAuth Token](https://oauth.yandex.ru/authorize?response_type=token&client_id=1a6990aa636648e9b2ef855fa7bec2fb)

## Main Part

### Preps

New branch **terraform-1**

Create main.tf at /terraform, with auth information. Better to use service account.
```
yc config list
```

[Yandex Terraform install](https://cloud.yandex.ru/docs/tutorials/infrastructure-management/terraform-quickstart#install-terraform)

```
$Env:YC_TOKEN=$(yc iam create-token)
$Env:YC_CLOUD_ID=$(yc config get cloud-id)
$Env:YC_FOLDER_ID=$(yc config get folder-id)

terraform providers lock -net-mirror=https://terraform-mirror.yandexcloud.net -platform=linux_amd64 -platform=darwin_arm64 -platform=windows_amd64 yandex-cloud/yandex
```

Trying to init
```
terraform init
terraform plan
terraform apply
terraform show
terraform destroy
```
Done!

Adding metadata with ssh key to **"app"** resource.
```
terraform apply
ssh ubuntu@<ip.yandex.app>
```
Done!

### Output variables
Make file **otputs.tf** at /terraform
```
terraform refresh
...
Outputs:
external_ip_address_app = "51.250.69.230"

terraform output
external_ip_address_app = "51.250.69.230"

terraform output external_ip_address_app
"51.250.69.230"
```
### Provisioners

```
provisioner "file" {
  source = "files/puma.service"
  destination = "/tmp/puma.service"
}
```

puma.service deploy.sh

Remote connection
```
terraform taint yandex_compute_instance.app
terraform plan
terraform apply -auto-approve
terraform destroy -auto-approve
```

На этом основная часть сделана. Переменные определены и применены.

## Bonus part

### Load balancer
[YC Network Load Balancer DOCs](https://cloud.yandex.ru/docs/network-load-balancer/quickstart)

[YC Load Balancer Instruction](https://cloud.yandex.ru/docs/network-load-balancer/operations/internal-lb-create)

[Terraform Yandex LB Docs](https://terraform-provider.yandexcloud.net/Resources/lb_network_load_balancer)

[Terraform Yandex LB Target Group](https://terraform-provider.yandexcloud.net/Resources/lb_target_group)

Duplicate reddit-app. Test. Ok!

Adding **count** variable

Create **lb.tf**
```
resource "yandex_lb_network_load_balancer" "foo" {
  name = "my-network-load-balancer"

  listener {
    name = "my-listener"
    port = 9292
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = "${yandex_lb_target_group.my-target-group.id}"

    healthcheck {
      name = "http"
      http_options {
        port = 9292
        path = "/"
      }
    }
  }
}
```
Start. Test. Destroy.

Небольшие проблемы с provisioning. Добавил в **deploy.sh** ожидание завершения **apt**
```
a=1; while [ -n "$(pgrep apt-get)" ]; do echo $a; sleep 1s; a=$(expr $a + 1); done
```

# Homework 5, Packer

## Main Part

[Packer Yandex plugin integration](https://developer.hashicorp.com/packer/integrations/hashicorp/yandex/latest/components/builder/yandex)

### Install packer
Download link https://hashicorp-releases.yandexcloud.net/packer/1.9.4/
```
wget packer.zip
unzip packer.zip
sudo mv packer /usr/local/bin
packer -v
```

### YC Service Account
```
yc config list
yc iam service-account create --name $SVC_ACCT --folder-id $FOLDER_ID
yc iam service-account get $SVC_ACCT
yc resource-manager folder add-access-binding --id $FOLDER_ID \
--role editor \
--service-account-id $ACCT_ID
yc iam key create --service-account-id $ACCT_ID --output <вставьте свой путь>/key.json
```

### Packer Template

Builder .json template [**ubuntu.json**](https://gist.githubusercontent.com/Yessos/c1a49ada622255f462a6e191a1dd39e2/raw/8fff42944adc24c22116838de114ef24eacab2b9/ubuntu16.json)

Template with provisioning [**ubuntu1.json**](https://gist.githubusercontent.com/Yessos/2f1917bd0101d88ebefd8e87b362fc6b/raw/5ffdf3819794f6d3917e37ef167cede50160cd5e/ubuntu16.json)

Packer plugin for YandexCloud [packer for yandex](https://cloud.yandex.com/en/docs/tutorials/infrastructure-management/packer-quickstart)

```
packer init .\config.pkr.hcl
packer validate .\ubuntu16.json
```

Error for network. Edit *ubuntu16.json* in *builders* add
```
"subnet_id": "e9bda6c3k22fog******",
"zone": "ru-central1-a",
"use_ipv4_nat": "true"
```
Building image
```
packer build .\ubuntu16.json
yc compute images list
```
Creating new VM with our image via Web

Done!

Deploy application reddit
```
ssh -i ~/.ssh/appuser appuser@<публичный IP машины>
sudo apt-get update
sudo apt-get install -y git
git clone -b monolith https://github.com/express42/reddit.git
cd reddit && bundle install
puma -d
```

Done!

### Exercise
[Packer Variables Usage](https://developer.hashicorp.com/packer/docs/templates/legacy_json_templates/user-variables)

Variables in .json
```
{
    "variable": "value"
}
```

Implementation
```
{
    "parameter": "{{user `variable`}}"
}
```

Testing
```
packer build -var-file=variables.json ubuntu.json
```
Starting by CLI
```
yc compute instance create `
--name reddit-app `
--zone ru-central1-a `
--hostname reddit-app `
--memory=2 `
--platform=standard-v3 `
--cores=2 `
--core-fraction 50 `
--create-boot-disk image-folder-id=<user-folder-id>,image-family=reddit-base `
--network-interface subnet-name=default-ru-central1-a,nat-ip-version=ipv4 `
--ssh-key C:\Users\****\.ssh\appuser.pub
```
Success!

## Bonus part

### Bake

**immutable.json** мы можем задеплоить приложение, но оно должно стартовать при запуске. Текущий скрипт содержит **puma -d** и эта часть не сохранится при "запекании". Нужно сделать скрипт, который будет автоматически запускаться как сервис.

[systemd service](https://linuxhandbook.com/create-systemd-services/) статья как сделать из нашего скрипта сервис.

Создаем **puma.service** по инструкции. Теперь надо добавить его в сборку и активировать сервис в образе.

Добавляем в **immutable.json**:
```
"provisioners": [
    {
            "type": "file",
            "source": "./files/puma.service",
            "destination": "/tmp/puma.service"
    },
    {
      "type": "shell",
      "inline": [
        "sudo mv /tmp/puma.service /etc/systemd/system/puma.service",
        ...
        "cd /monolith/reddit && bundle install",
        "sudo systemctl daemon-reload",
        "sudo systemctl start puma",
        "sudo systemctl enable puma"
      ]
    }
```

Что бы использовать образы из **reddit-base**, packer должен знать где их искать. Добавляем в json *"source_image_folder_id"* со значением нашего *folder_id*
[packer yandex builder](https://developer.hashicorp.com/packer/integrations/hashicorp/yandex/latest/components/builder/yandex)
```
"builders": [
    {
      "type": "yandex",
      ...
      "source_image_folder_id": "{{ user `folder_id`}}",
      "source_image_family": "reddit-base",
```

Собираем образ с установленным приложением
```
packer build -var-file=".\variables.json" .\immutable.json
```

Запускаем ВМ на образе **reddit-full**
```
yc compute instance create `
 --name reddit-app `
 --zone ru-central1-a `
 --hostname reddit-app `
 --platform=standard-v3 --cores=2 --memory=2 --core-fraction 50 `
 --create-boot-disk source-image-folder-id=b1gk6gb6l49ucpjkrmtr,image-family=reddit-full `
 --network-interface subnet-name=default-ru-central1-a,nat-ip-version=ipv4 `
 --ssh-key ...
```

Ждем когда поднимется инстанс. Вуа-ля! Приложение работает из коробки.

### Automate
Упаковываем все в скрипт **create-reddit-vm.sh**

# Homework 4, Test Application Deploy and Run:

## Main Part
### Variables for Tests
```
testapp_IP = 158.160.117.127
testapp_port = 9292
```

### Git checkout
```
git checkout -b cloud-testapp
git mv cloud-bastion.ovpn ./VPN/
git mv setupvpn.sh ./VPN/
```

### Yandex Cloud CLI
Необходимо использовать версию образа указанную в проекте **ubuntu-1604-lts**
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
Собираем все что набили выше в скрипты и добавляем в гите атрибуты исполняемости
```
git update-index --chmod=+x install_ruby.sh
git update-index --chmod=+x install_mongodb.sh
git update-index --chmod=+x deploy.sh
```

## Bonus Part

### Bash Script for deploy

Собираем все в один скрипт **startup.yaml**, внутри будет и скрипт и пользовательские данные

Теперь запускаем ВМ которая сразу запускается с нашим приложением через CLI

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
--metadata-from-file user-data=startup.yaml
```

# Homework 3, SSH Proxy Jump

## Основное задание

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

## Бонусное задание

### SSH Config Alias
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

[How to make README readable](https://www.markdownguide.org/basic-syntax/)
