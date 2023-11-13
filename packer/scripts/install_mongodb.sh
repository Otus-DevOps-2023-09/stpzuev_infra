#!/bin/bash
a=1; while [ -n "$(pgrep apt-get)" ]; do echo $a; sleep 1s; a=$(expr $a + 1); done
apt update
apt install -y mongodb
sed -i 's/bind_ip = 127.0.0.1/bind_ip = 0.0.0.0/g' /etc/mongodb.conf
systemctl start mongodb
systemctl enable mongodb

sleep 5

CHECK_MONGO=`systemctl list-units | grep mongo | grep running`
if [ -n "$CHECK_MONGO" ]; then
echo "---MongoDB installed and running---"
else echo "---MongoDB not installed and running---"
fi
