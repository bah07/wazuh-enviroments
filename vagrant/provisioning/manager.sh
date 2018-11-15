#!/bin/bash

sudo su
# Set time zone
timedatectl set-timezone Europe/Madrid

if [ $1 = "ubuntu" ]; then
    # Repositories
    curl -s https://s3-us-west-1.amazonaws.com/packages.wazuh.com/key/GPG-KEY-WAZUH | apt-key add -
    echo "deb https://s3-us-west-1.amazonaws.com/packages.wazuh.com/3.x/apt/ stable main" | tee -a /etc/apt/sources.list.d/wazuh.list
    echo "deb https://s3-us-west-1.amazonaws.com/packages.wazuh.com/3.x/apt-dev/ unstable main" | tee -a /etc/apt/sources.list.d/wazuh.list

    # Install manager
    apt-get update
    apt-get install curl apt-transport-https lsb-release -y
    apt-get -y install wazuh-manager=$2*
elif [ $1 = "centos" ]; then
    # Repositories
    echo -e '[wazuh_repo]\ngpgcheck=1\ngpgkey=https://s3-us-west-1.amazonaws.com/packages.wazuh.com/key/GPG-KEY-WAZUH\nenabled=1\nname=EL-$releasever - Wazuh\nbaseurl=https://s3-us-west-1.amazonaws.com/packages.wazuh.com/3.x/yum/\nprotect=1' | tee /etc/yum.repos.d/wazuh_dev.repo
    echo -e '[wazuh_repo_dev]\ngpgcheck=1\ngpgkey=https://s3-us-west-1.amazonaws.com/packages.wazuh.com/key/GPG-KEY-WAZUH\nenabled=1\nname=EL-$releasever - Wazuh\nbaseurl=https://s3-us-west-1.amazonaws.com/packages.wazuh.com/3.x/yum-dev/\nprotect=1' | tee /etc/yum.repos.d/wazuh_dev.repo

    # Install manager
    yum install -y nano wazuh-manager-$2*
else
    exit 1
fi

# Wazuh-tools
mv /vagrant/wazuh_shell /root/.wazuh_shell
echo ". $HOME/.wazuh_shell" >> /root/.bashrc

/var/ossec/bin/ossec-authd -dd
