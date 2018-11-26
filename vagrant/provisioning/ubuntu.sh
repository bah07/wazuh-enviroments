#!/bin/bash

os="ubuntu"
type=$1
version=$2
ip_manager=$3
ip_agent=$4
installation=$5

echo "Configuring $os $branch via $installation"

# Wazuh-tools
mv /vagrant/wazuh_shell /root/.wazuh_shell
echo ". $HOME/.wazuh_shell" >> /root/.bashrc
source /root/.bashrc

if [ $installation = "packages" ]; then
    apt-get install net-tools nano -y
    # Repositories
    curl -s https://s3-us-west-1.amazonaws.com/packages.wazuh.com/key/GPG-KEY-WAZUH | apt-key add -
    echo "deb https://s3-us-west-1.amazonaws.com/packages.wazuh.com/3.x/apt/ stable main" | tee -a /etc/apt/sources.list.d/wazuh.list
    echo "deb https://s3-us-west-1.amazonaws.com/packages.wazuh.com/3.x/apt-dev/ unstable main" | tee -a /etc/apt/sources.list.d/wazuh.list

    # Install manager
    apt-get install -y nano wazuh-$type-$version*
elif
    apt-get install git make gcc gdb automake autoconf libtool nano net-tools -y
    git fetch
    cd /home/vagrant
    git clone https://github.com/wazuh/wazuh -b $branch wazuh
    cd wazuh/src
    make clean-internals
    make deps
    make TARGET=$type DEBUG=true
    ossec-uninstall
    (echo "";echo "";sleep 0.2;echo "$type";sleep 0.2;echo "";) | bash ../install.sh
fi

if [ $type = "agent" ]; then
    # Configuring
    sed -i "s=<address>.*</address>=<address>$ip_manager</address>=g" /var/ossec/etc/ossec.conf
    # Register
    agent-auth -m $ip_manager -I $ip_agent -A $type-$os-$branch
    ossec-control start
elif
    ossec-authd -d
fi
