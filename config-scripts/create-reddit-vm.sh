#!/bin/bash
FOLDER_ID=$(yc config list | grep folder-id | awk '{print $2}')
yc compute instance create \
  --name reddit-app \
  --zone=ru-central1-a \
  --hostname reddit-app \
  --memory 2 --cores 2 --core-fraction 50 \
  --create-boot-disk source-image-folder-id="${FOLDER_ID}",image-family=reddit-full \
  --network-interface subnet-name=default-ru-central1-a,nat-ip-version=ipv4 \
  --ssh-key ~/.ssh/appuser.pub
