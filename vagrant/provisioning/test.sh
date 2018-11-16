#!/bin/bash

ip="10.0.0.2"
os="ubuntu"
version="3.7"

echo "Configuring ubuntu via sources"
apt-get update
apt-get install git make gcc gdb automake autoconf libtool nano -y
git fetch
cd /vagrant
git clone https://github.com/wazuh/wazuh.git -b $version wazuh
cd wazuh/src
make clean
make deps
make TARGET=agent DEBUG=true
(echo "";echo "";sleep 0.2;echo "agent";sleep 0.2;echo "";) | bash ../install.sh

# Wazuh-tools
mv /vagrant/wazuh_shell /root/.wazuh_shell
echo ". $HOME/.wazuh_shell" >> /root/.bashrc

# Configuring
sed -i "s=<address>.*</address>=<address>$ip</address>=g" /var/ossec/etc/ossec.conf

# Register  
/var/ossec/bin/agent-auth -m $ip -A ag-$os-$version
/var/ossec/bin/ossec-control start