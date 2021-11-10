#!/bin/bash
sudo su
sudo yum install -y httpd
echo "<p> Hello, World! </p>" >> /var/www/html/index.html
sudo systemctl enable httpd
sudo systemctl start httpd