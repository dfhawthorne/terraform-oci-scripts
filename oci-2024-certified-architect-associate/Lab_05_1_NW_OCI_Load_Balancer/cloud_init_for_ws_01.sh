#!/bin/bash -x
iptables -A INPUT -p tcp -m multiport --dports 80,443 -j ACCEPT
yum -y install httpd
systemctl enable httpd.service
systemctl start httpd.service
firewall-offline-cmd --add-service=http
firewall-offline-cmd --add-service=https
systemctl enable firewalld
systemctl start firewalld
echo Hello World! My name is FRA-AA-LAB05-WS-02 >/var/www/html/index.html

