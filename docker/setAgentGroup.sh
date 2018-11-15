#!/bin/bash

max=$1
group=$3
version=$2
id=0

for ip in 172.18.{0..255}.{0..255}; do
    if [ $ip == "172.18.0.0" ] || [ $ip == "172.18.0.1" ]; then
        continue
    fi

    cname=wag-$version-centos-$id
    echo "Exec '$command' in $cname"
    docker exec $cname "/var/ossec/bin/agent_group -a -i 'agent_id' -g group_id" &

    id=$[ $id + 1 ]

    if [ $max -lt $id ]; then
        break
    fi
done
