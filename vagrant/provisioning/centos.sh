#!/bin/bash

os="centos"
type=$1
version=$2
ip_manager=$3
ip_agent=$4
installation=$5


echo "Configuring $os $branch via $installation"
if [ $installation = "packages" ]; then
    yum install net-tools nano -y
    # Repositories
    echo -e '[wazuh_repo]\ngpgcheck=1\ngpgkey=https://s3-us-west-1.amazonaws.com/packages.wazuh.com/key/GPG-KEY-WAZUH\nenabled=1\nname=EL-$releasever - Wazuh\nbaseurl=https://s3-us-west-1.amazonaws.com/packages.wazuh.com/3.x/yum/\nprotect=1' | tee /etc/yum.repos.d/wazuh_dev.repo
    echo -e '[wazuh_repo_dev]\ngpgcheck=1\ngpgkey=https://s3-us-west-1.amazonaws.com/packages.wazuh.com/key/GPG-KEY-WAZUH\nenabled=1\nname=EL-$releasever - Wazuh\nbaseurl=https://s3-us-west-1.amazonaws.com/packages.wazuh.com/3.x/yum-dev/\nprotect=1' | tee /etc/yum.repos.d/wazuh_dev.repo

    # Install manager
    yum install -y nano wazuh-$type-$version*
elif
    yum install git make gcc gdb automake autoconf libtool nano net-tools -y
    git fetch
    cd /home/vagrant
    git clone https://github.com/wazuh/wazuh -b $branch wazuh
    cd wazuh/src
    make clean-internals
    make deps
    make TARGET=$type DEBUG=true
    (echo "";echo "";sleep 0.2;echo "$type";sleep 0.2;echo "";) | bash ../install.sh
fi

# Wazuh-tools
mv /vagrant/wazuh_shell /root/.wazuh_shell
echo ". $HOME/.wazuh_shell" >> /root/.bashrc
source /root/.bashrc

if [ $type = "agent" ]; then
    # Configuring
    sed -i "s=<address>.*</address>=<address>$ip_manager</address>=g" /var/ossec/etc/ossec.conf
    # Register
    agent-auth -m $ip_manager -I $ip_agent -A $type-$os-$branch
    ossec-control start
elif
    ossec-authd -d
fi
