#!/bin/bash
apt update
apt install -y mongodb
systemctl start mongodb
systemctl enable mongodb
