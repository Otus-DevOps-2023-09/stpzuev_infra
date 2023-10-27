#!/bin/bash
echo "deb http://repo.pritunl.com/stable/apt jammy main" | sudo tee /etc/apt/sources.list.d/pritunl.list
apt-key adv --keyserver hkp://keyserver.ubuntu.com --recv 7568D9BB55FF9E5287D586017AE645C0CF8E292A
curl https://raw.githubusercontent.com/pritunl/pgp/master/pritunl_repo_pub.asc | sudo apt-key add -
echo "deb https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-7.0.list
wget -qO - https://www.mongodb.org/static/pgp/server-7.0.asc | sudo apt-key add -
apt update
apt -y install wireguard wireguard-tools
ufw disable
apt -y install mongodb-org
apt -y install pritunl
systemctl enable mongod pritunl
systemctl start mongod pritunl
