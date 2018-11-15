#!/bin/bash

sudo su
# Set time zone
timedatectl set-timezone Europe/Madrid

if [ $1 = "ubuntupkg" ]; then
    # Repositories
    curl -s https://s3-us-west-1.amazonaws.com/packages.wazuh.com/key/GPG-KEY-WAZUH | apt-key add -
    echo "deb https://s3-us-west-1.amazonaws.com/packages.wazuh.com/3.x/apt/ stable main" | tee -a /etc/apt/sources.list.d/wazuh.list
    echo "deb https://s3-us-west-1.amazonaws.com/packages.wazuh.com/3.x/apt-dev/ unstable main" | tee -a /etc/apt/sources.list.d/wazuh.list

    # Install manager
    apt-get update
    apt-get -y install wazuh-agent=$2*
elif [ $1 = "centospkg" ]; then
    # Repositories
    echo -e '[wazuh_repo]\ngpgcheck=1\ngpgkey=https://s3-us-west-1.amazonaws.com/packages.wazuh.com/key/GPG-KEY-WAZUH\nenabled=1\nname=EL-$releasever - Wazuh\nbaseurl=https://s3-us-west-1.amazonaws.com/packages.wazuh.com/3.x/yum/\nprotect=1' | tee /etc/yum.repos.d/wazuh_dev.repo
    echo -e '[wazuh_repo_dev]\ngpgcheck=1\ngpgkey=https://s3-us-west-1.amazonaws.com/packages.wazuh.com/key/GPG-KEY-WAZUH\nenabled=1\nname=EL-$releasever - Wazuh\nbaseurl=https://s3-us-west-1.amazonaws.com/packages.wazuh.com/3.x/yum-dev/\nprotect=1' | tee /etc/yum.repos.d/wazuh_dev.repo

    # Install manager
    yum install -y nano wazuh-agent-$2*
elif [ $1 = "centosbranch" ]; then
    yum install automake autoconf libtool git nano gdb -y
    git fetch
    git clone https://github.com/wazuh/wazuh.git -b $4
    cd wazuh/src
    make clean
    make deps
    make TARGET=agent DEBUG=true
    (
    echo "";sleep 0.5;
    echo "en";sleep 0.2;
    echo "server"; sleep 0.2;
    echo "";
    echo "";
    echo "";
    echo "";
    ) | bash /vagrant/wazuh/install.sh
elif [ $1 = "ubuntubranch" ]; then
    apt-get update
    apt install automake autoconf libtool git nano gdb -y
    git fetch
    git clone https://github.com/wazuh/wazuh.git -b $4
    cd wazuh/src
    make clean
    make deps
    make TARGET=agent DEBUG=true
    (
    echo "";sleep 0.5;
    echo "en";sleep 0.2;
    echo "server"; sleep 0.2;
    echo "";
    echo "";
    echo "";
    echo "";
    ) | bash /vagrant/wazuh/install.sh
else
    exit 1
fi



# Wazuh-tools
mv /vagrant/wazuh_shell /root/.wazuh_shell
echo ". $HOME/.wazuh_shell" >> /root/.bashrc

# Configuring
sed -i "s=<address>.*</address>=<address>$3</address>=g" /var/ossec/etc/ossec.conf

# Register  
/var/ossec/bin/agent-auth -m $3 -A ag-$1-$2
/var/ossec/bin/ossec-control start