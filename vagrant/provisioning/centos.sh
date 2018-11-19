#!/bin/bash

sobox=$1
type=$2
branch=$3
os="centos"
ip_manager=$4
ip_agent=$5

# Wazuh-tools
mv /vagrant/wazuh_shell /root/.wazuh_shell
echo ". $HOME/.wazuh_shell" >> /root/.bashrc

echo "Configuring centos via sources"
yum install git make gcc gdb automake autoconf libtool nano -y
git fetch
cd /home/vagrant
git clone https://github.com/wazuh/wazuh -b $branch wazuh
cd wazuh/src
make clean-internals
make deps
make TARGET=$type DEBUG=true
(echo "";echo "";sleep 0.2;echo "agent";sleep 0.2;echo "";) | bash ../install.sh

# Configuring
sed -i "s=<address>.*</address>=<address>$ip_manager</address>=g" /var/ossec/etc/ossec.conf

# Register
/var/ossec/bin/agent-auth -m $ip_manager -I $ip_agent -A $type-$os-$branch
/var/ossec/bin/ossec-control start
