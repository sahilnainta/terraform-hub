#!/bin/bash
sudo su
echo "<p> Hello, World! </p>" >> /var/www/html/index.html
sudo systemctl enable httpd
sudo systemctl start httpd