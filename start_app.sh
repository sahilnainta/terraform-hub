#!/bin/bash

echo "---------- startup script ---------"

sudo su - ec2-user

sudo systemctl start nginx

source /home/ec2-user/.bashrc

redis-server --daemonize yes

### prod checkout & setup
cd /home/ec2-user
sudo rm -rf prod && mkdir prod
cd /home/ec2-user/prod

# fetch latest tag
latestTag=$(sudo git ls-remote --tags --refs --sort="v:refname" https://32nd-hub-admin:ATBB3x8GXLXgqaNv9TV7MWS66GTSBD45A5F0@bitbucket.org/sahil32nd/hub-nodejs.git | tail -n1 | sed 's/.*\///')

# clone latest tag
sudo git clone --depth 1 -b $latestTag https://32nd-hub-admin:ATBB3x8GXLXgqaNv9TV7MWS66GTSBD45A5F0@bitbucket.org/sahil32nd/hub-nodejs.git

cd hub-nodejs
cp .env.production .env

yarn install

# start production PM2
cd /home/ec2-user/prod/hub-nodejs
PM2_HOME=/home/ec2-user/.pm2 pm2 start src/index.js -i max --node-args="-r esm" --wait-ready --name "prod-club-graphql"
pm2 save


### staging checkout & setup
cd /home/ec2-user
sudo rm -rf staging && mkdir staging
cd /home/ec2-user/staging
git clone -b master https://32nd-hub-admin:ATBB3x8GXLXgqaNv9TV7MWS66GTSBD45A5F0@bitbucket.org/sahil32nd/hub-nodejs.git
cd hub-nodejs
cp .env.staging .env

yarn install

# start staging PM2
cd /home/ec2-user/staging/hub-nodejs
PM2_HOME=/home/ec2-user/.pm2 pm2 start src/index.js -i max --node-args="-r esm" --wait-ready --name "staging-club-graphql"
pm2 save


### qa checkout & setup
cd /home/ec2-user
sudo rm -rf qa && mkdir qa
cd /home/ec2-user/qa
git clone -b master https://32nd-hub-admin:ATBB3x8GXLXgqaNv9TV7MWS66GTSBD45A5F0@bitbucket.org/sahil32nd/hub-nodejs.git
cd hub-nodejs
cp .env.qa .env

yarn install

# start qa PM2
cd /home/ec2-user/qa/hub-nodejs
PM2_HOME=/home/ec2-user/.pm2 pm2 start src/index.js -i max --node-args="-r esm" --wait-ready --name "qa-club-graphql"
pm2 save


### dev checkout & setup
cd /home/ec2-user
sudo rm -rf dev && mkdir dev
cd /home/ec2-user/dev
git clone -b master https://32nd-hub-admin:ATBB3x8GXLXgqaNv9TV7MWS66GTSBD45A5F0@bitbucket.org/sahil32nd/hub-nodejs.git
cd hub-nodejs
cp .env.dev .env

yarn install

# start dev PM2
cd /home/ec2-user/dev/hub-nodejs
PM2_HOME=/home/ec2-user/.pm2 pm2 start src/index.js -i max --node-args="-r esm" --wait-ready --name "dev-club-graphql"
pm2 save

# sudo chown ec2-user:ec2-user /home/ec2-user/.pm2/rpc.sock /home/ec2-user/.pm2/pub.sock
sudo chown ec2-user:ec2-user /home/ec2-user/.pm2/rpc.sock /home/ec2-user/.pm2/pub.sock /home/ec2-user/.pm2/reload.lock
# yarn install from ec2-user & PM2 logging
sudo chown -R ec2-user /home/ec2-user/prod /home/ec2-user/staging /home/ec2-user/qa /home/ec2-user/dev /home/ec2-user/.pm2

# TODO: Hardcoded name 'club-xxxx' needs to be picked from terraform.tfvars