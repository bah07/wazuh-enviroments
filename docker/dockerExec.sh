#!/bin/bash

max=$1
version=$2
command=$3
id=101

for ip in 172.18.{0..255}.{0..255}; do
    if [ $ip == "172.18.0.0" ] || [ $ip == "172.18.0.1" ]; then
        continue
    fi

    cname=wag-$version-centos-$id
    echo "Exec '$command' in $cname"
    docker exec $cname $command


    if [ $id -eq $max ]; then
        break
    fi
    id=$[ $id + 1 ]
done



