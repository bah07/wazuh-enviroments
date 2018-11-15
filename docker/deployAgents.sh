#!/bin/bash

# Usage:
# crear red
# docker network create --subnet=172.18.0.0/16 wazuhnet
# crear imagen
# docker build --build-arg VER=-3.7.0 -t wag-centos:3.7 -f Dockerfile .
#
# ./deployAgent <num_containers> <image> <version>
#

# Check root
if ! [ $(id -u) = 0 ]; then
  echo -e "You must be root"
  exit 1
fi

if [ $# -lt 1 ]; then
  exit 1
fi

shared="/home/borja/archivos/docker/shared"
id=1
max=$1
image=$2
version=$3

for ip in 172.17.{0..250}.{2..252}; do
    cname=$image-$version-$id
    #docker run --privileged -i --network wazuhnet --ip 172.18.0.2 --volume /home/borja/archivos/docker/shared:/shared --hostname=wag-centos-3.7.0-1 --name=wag-centos-3.7.0-1 wag-centos:3.7.0 /usr/local/bin/run -m 172.17.0.1 -dd
    docker run --privileged -i --volume $shared:/shared --hostname=$cname --name=$cname $image:$version tail -f /dev/null &
    echo "Container $cname created at '$ip'..."

    if [ $id -eq $max ]; then
    break
    fi
    id=$[ $id + 1 ]
done    
