
FROM centos
ARG VER=''

COPY wazuh.repo /etc/yum.repos.d
COPY wazuh_dev.repo /etc/yum.repos.d
COPY wazuh_shell /root/.wazuh_shell
COPY run /usr/local/bin/run

RUN echo ". $HOME/.wazuh_shell" >> /root/.bashrc
RUN yum -y install wazuh-agent$VER nano
ENV PATH=$PATH:/var/ossec/bin




# docker build --build-arg VER=-3.7.0 -t wag-centos:3.7.0 -f Dockerfile .
# /usr/local/bin/run -m 172.17.0.1 -dd