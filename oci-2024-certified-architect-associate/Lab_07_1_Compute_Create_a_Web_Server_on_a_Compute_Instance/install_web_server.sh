#!/usr/bin/bash
# ------------------------------------------------------------------------------
# Lab 07-1: Compute: Create a Web Server on a Compute Instance
#   Install an Apache HTTP Server on the Instance
# ------------------------------------------------------------------------------

sudo yum install httpd -y
sudo apachectl start
sudo systemctl enable httpd
sudo apachectl configtest
sudo firewall-cmd --permanent --zone=public --add-service=http
sudo firewall-cmd --reload
sudo bash -c 'echo This is my Web-Server running on Oracle Cloud Infrastructure >> /var/www/html/index.html'
