#!/bin/bash

echo "---------- startup script ---------"

sudo su - ec2-user

sudo systemctl start nginx

source /home/ec2-user/.bashrc

# prod checkout & setup
cd /home/ec2-user
mkdir prod
cd /home/ec2-user/prod
sudo rm -rf hub-nodejs
git clone --depth 1 -b master https://sahilnainta:sahil32nd@bitbucket.org/vikas_gh/hub-nodejs.git
cd hub-nodejs
cp .env.production .env

yarn install

# staging checkout & setup
cd /home/ec2-user
mkdir staging
cd /home/ec2-user/staging
sudo rm -rf hub-nodejs
git clone --depth 1 -b master https://sahilnainta:sahil32nd@bitbucket.org/vikas_gh/hub-nodejs.git
cd hub-nodejs
cp .env.staging .env

yarn install

# qa checkout & setup
cd /home/ec2-user
mkdir qa
cd /home/ec2-user/qa

git clone --depth 1 -b master https://sahilnainta:sahil32nd@bitbucket.org/vikas_gh/hub-nodejs.git
cd hub-nodejs
cp .env.qa .env

yarn install

# dev checkout & setup
cd /home/ec2-user
mkdir dev
cd /home/ec2-user/dev

git clone --depth 1 -b master https://sahilnainta:sahil32nd@bitbucket.org/vikas_gh/hub-nodejs.git
cd hub-nodejs
cp .env.dev .env

yarn install


# start production PM2
cd /home/ec2-user/prod/hub-nodejs
PM2_HOME=/home/ec2-user/.pm2 pm2 start src/index.js -i max --node-args="-r esm" --wait-ready --name "prod-hub-graphql"
pm2 save

# start staging PM2
cd /home/ec2-user/staging/hub-nodejs
PM2_HOME=/home/ec2-user/.pm2 pm2 start src/index.js -i max --node-args="-r esm" --wait-ready --name "staging-hub-graphql"
pm2 save

# start qa PM2
cd /home/ec2-user/qa/hub-nodejs
PM2_HOME=/home/ec2-user/.pm2 pm2 start src/index.js -i max --node-args="-r esm" --wait-ready --name "qa-hub-graphql"
pm2 save

# start dev PM2
cd /home/ec2-user/dev/hub-nodejs
PM2_HOME=/home/ec2-user/.pm2 pm2 start src/index.js -i max --node-args="-r esm" --wait-ready --name "dev-hub-graphql"
pm2 save

sudo chown ec2-user:ec2-user /home/ec2-user/.pm2/rpc.sock /home/ec2-user/.pm2/pub.sock