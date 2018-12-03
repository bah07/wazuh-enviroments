#!/bin/bash

os="ubuntu"
type=$1
version=$2
ip_manager=$3
installation=$4

# Wazuh-tools
mv /home/vagrant/shared/wazuh_shell /root/.wazuh_shell
echo ". $HOME/.wazuh_shell" >> /root/.bashrc
source /root/.bashrc

echo "Configuring $os $version via $installation"
if [ $installation = "packages" ]; then
    apt-get install net-tools nano -y
    # DEV Repositories
    curl -s https://s3-us-west-1.amazonaws.com/packages-dev.wazuh.com/key/GPG-KEY-WAZUH | apt-key add -
    echo "deb https://s3-us-west-1.amazonaws.com/packages-dev.wazuh.com/pre-release/apt/ unstable main" | tee -a /etc/apt/sources.list.d/wazuh_pre_release.list
    # Repositories
    echo "deb https://s3-us-west-1.amazonaws.com/packages.wazuh.com/3.x/apt/ stable main" | tee -a /etc/apt/sources.list.d/wazuh.list

    # Install manager
    yum install wazuh-$type-$version* -y
else
    apt-get install git make gcc gdb automake autoconf libtool net-tools nano -y
    git fetch
    cd /home/vagrant
    git clone https://github.com/wazuh/wazuh -b $version wazuh
    cd ./wazuh/src
    make clean-internals
    make deps
    make TARGET=$type DEBUG=true
    (echo "";echo "";sleep 0.2;echo "$type";sleep 0.2;echo "";) | ../install.sh
fi

if [ $type = "agent" ]; then
    # Configuring
    sed -i "s=<address>.*</address>=<address>$ip_manager</address>=g" /var/ossec/etc/ossec.conf
    # Register
    agent-auth -m $ip_manager -A $type-$os-$version
    ossec-control start
else
    ossec-authd -d
fi
