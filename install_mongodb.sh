#!/bin/bash
apt update
apt install -y mongodb
systemctl enable mongodb
systemctl start mongodb
