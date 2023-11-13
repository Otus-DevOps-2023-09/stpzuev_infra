#!/bin/bash

if [[ $1 == "--list" ]]; then
#    APPHOST=$(yc compute instance get --name reddit-app-stage --format=json | jq -r '.network_interfaces[0].primary_v4_address.one_to_one_nat.address')
#    DBHOST=$(yc compute instance get --name reddit-db-stage --format=json | jq -r '.network_interfaces[0].primary_v4_address.address')
APPHOST=158.160.48.94
DBHOST=10.128.0.28

    cat <<EOT
{
    "_meta": {
        "hostvars": {}
    },
    "app": {
        "hosts": ["${APPHOST}"]
    },
    "db": {
        "hosts": ["${DBHOST}"],
        "vars": {
            "ansible_ssh_common_args": "-J ubuntu@${APPHOST}"
        }
    }
}
EOT

elif [[ $1 == "--host" ]]; then
    echo '{"_meta": {"hostvars": {}}}' | jq -M
else
    echo '{}'
fi
