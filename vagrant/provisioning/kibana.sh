#!/bin/bash

yum install net-tools git zip ntp nano -y

# Remove firewalld
yum remove firewalld -y
ntpdate -s time.nist.gov

curl -Lo jre-8-linux-x64.rpm --header "Cookie: oraclelicense=accept-securebackup-cookie" "https://download.oracle.com/otn-pub/java/jdk/8u191-b12/2787e4a523244c269598db4e85c51e0c/jre-8u191-linux-x64.rpm"
yum -y install jre-8-linux-x64.rpm -y
rm -f jre-8-linux-x64.rpm

rpm --import https://packages.elastic.co/GPG-KEY-elasticsearch

cat > /etc/yum.repos.d/elastic.repo << EOF
[elasticsearch-6.x]
name=Elasticsearch repository for 6.x packages
baseurl=https://artifacts.elastic.co/packages/6.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
EOF

yum install elasticsearch-6.5.1 -y

systemctl daemon-reload
systemctl enable elasticsearch.service
systemctl start elasticsearch.service

sleep 15

curl https://raw.githubusercontent.com/wazuh/wazuh/3.7/extensions/elasticsearch/wazuh-elastic6-template-alerts.json | curl -X PUT "http://localhost:9200/_template/wazuh" -H 'Content-Type: application/json' -d @-

yum install logstash-6.5.1 -y
curl -so /etc/logstash/conf.d/01-wazuh.conf https://raw.githubusercontent.com/wazuh/wazuh/3.7/extensions/logstash/01-wazuh-remote.conf

systemctl daemon-reload
systemctl enable logstash.service
systemctl start logstash.service

yum install kibana-6.5.1 -y

# Enable Elastic services
systemctl daemon-reload
systemctl enable kibana

# Repo dev
sudo -u kibana NODE_OPTIONS="--max-old-space-size=3072" /usr/share/kibana/bin/kibana-plugin install https://s3-us-west-1.amazonaws.com/packages.wazuh.com/3.x/wazuhapp-dev/wazuhapp-3.7.1_6.5.1-0.0415dev.zip
# Repositorio
# sudo -u kibana NODE_OPTIONS="--max-old-space-size=3072" /usr/share/kibana/bin/kibana-plugin install https://packages.wazuh.com/wazuhapp/wazuhapp-3.7.0_6.5.1.zip

# Kibana configuration
sed -i 's:\#server.host\: "localhost":server\.host\: "0.0.0.0":g' /etc/kibana/kibana.yml
sed -i 's:#elasticsearch.url:elasticsearch.url:g' /etc/kibana/kibana.yml
sed -i "s#http://localhost:9200#http://localhost:9200#g" /etc/kibana/kibana.yml

# Run Kibana
systemctl restart kibana
