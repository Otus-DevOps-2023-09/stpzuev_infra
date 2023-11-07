#!/bin/bash
a=1; while [ -n "$(pgrep apt-get)" ]; do echo $a; sleep 1s; a=$(expr $a + 1); done
apt update
apt install -y ruby-full ruby-bundler build-essential
