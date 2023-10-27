#!/bin/bash

sudo apt install -y mongodb
sudp systemctl enable mongodb
sudo systemctl start mongodb
