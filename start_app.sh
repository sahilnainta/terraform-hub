#!/bin/bash

echo "---------- startup script ---------"

sudo su - ec2-user

sudo systemctl start nginx

source /home/ec2-user/.bashrc

cd /home/ec2-user

sudo rm -rf hub-nodejs
git clone --depth 1 -b master https://sahilnainta:sahil32nd@bitbucket.org/vikas_gh/hub-nodejs.git

cd /home/ec2-user/hub-nodejs
cp .env.example .env

yarn install

PM2_HOME=/home/ec2-user/.pm2 pm2 start src/index.js -i max --node-args="-r esm" --wait-ready --name "hub-graphql"
pm2 save

sudo chown ec2-user:ec2-user /home/ec2-user/.pm2/rpc.sock /home/ec2-user/.pm2/pub.sock