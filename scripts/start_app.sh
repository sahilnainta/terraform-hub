#!/bin/bash

echo "---------- startup script ---------"

sudo su - ec2-user

sudo systemctl start nginx

source /home/ec2-user/.bashrc

# redis-server --daemonize yes

### prod checkout & setup
cd /home/ec2-user
sudo rm -rf prod && mkdir prod
cd /home/ec2-user/prod

# fetch latest tag
latestTag=$(git ls-remote --tags --refs --sort="v:refname" https://32nd-hub-admin:<APP_KEY>@bitbucket.org/sahil32nd/hub-nodejs.git | tail -n1 | sed 's/.*\///')

# clone latest tag
git clone --depth 1 -b $latestTag https://32nd-hub-admin:<APP_KEY>@bitbucket.org/sahil32nd/hub-nodejs.git

cd hub-nodejs
cp .env.production .env

yarn install
yarn build

# start production PM2
prod="prod-club-graphql"
cd /home/ec2-user/prod/hub-nodejs
PM2_HOME=/home/ec2-user/.pm2 pm2 start build/index.js -i max --wait-ready --name $prod
pm2 save


### developer envirnoment checkout
cd /home/ec2-user
sudo rm -rf club-app && mkdir club-app
cd /home/ec2-user/club-app
git clone -b master https://32nd-hub-admin:<APP_KEY>@bitbucket.org/sahil32nd/hub-nodejs.git
cd hub-nodejs
yarn install
yarn build

# start staging PM2
cd /home/ec2-user
sudo rm -rf staging && cp -R club-app staging
cd /home/ec2-user/staging/hub-nodejs
cp .env.staging .env

stag="staging-club-graphql"
PM2_HOME=/home/ec2-user/.pm2 pm2 start build/index.js -i max --wait-ready --name $stag
pm2 save

# # start staging1 PM2
# cd /home/ec2-user
# sudo rm -rf staging1 && cp -R staging staging1
# cd /home/ec2-user/staging1/hub-nodejs
# echo "APP_PORT=6001" >> .env

# stag="staging1-club-graphql"
# PM2_HOME=/home/ec2-user/.pm2 pm2 start build/index.js -i max --wait-ready --name $stag
# pm2 save

# # start qa PM2
# cd /home/ec2-user
# sudo rm -rf qa && cp -R club-app qa
# cd /home/ec2-user/qa/hub-nodejs
# cp .env.qa .env

# qa="qa-club-graphql"
# PM2_HOME=/home/ec2-user/.pm2 pm2 start build/index.js -i max --wait-ready --name $qa
# pm2 save

# # start qa1 PM2
# cd /home/ec2-user
# sudo rm -rf qa1 && cp -R qa qa1
# cd /home/ec2-user/qa1/hub-nodejs
# echo "APP_PORT=7001" >> .env

# stag="qa1-club-graphql"
# PM2_HOME=/home/ec2-user/.pm2 pm2 start build/index.js -i max --wait-ready --name $stag
# pm2 save

# # start dev PM2
# cd /home/ec2-user
# sudo rm -rf dev && cp -R club-app dev
# cd /home/ec2-user/dev/hub-nodejs
# cp .env.dev .env

# dev="dev-club-graphql"
# PM2_HOME=/home/ec2-user/.pm2 pm2 start build/index.js -i max --wait-ready --name $dev
# pm2 save

# # start dev1 PM2
# cd /home/ec2-user
# sudo rm -rf dev1 && cp -R dev dev1
# cd /home/ec2-user/dev1/hub-nodejs
# echo "APP_PORT=8001" >> .env

# stag="dev1-club-graphql"
# PM2_HOME=/home/ec2-user/.pm2 pm2 start build/index.js -i max --wait-ready --name $stag
# pm2 save

## Removing developer envirnoment directory 
cd /home/ec2-user
sudo rm -rf club-app

# sudo chown ec2-user:ec2-user /home/ec2-user/.pm2/rpc.sock /home/ec2-user/.pm2/pub.sock
sudo chown ec2-user:ec2-user /home/ec2-user/.pm2/rpc.sock /home/ec2-user/.pm2/pub.sock /home/ec2-user/.pm2/reload.lock
# yarn install from ec2-user & PM2 logging
sudo chown -R ec2-user /home/ec2-user/prod /home/ec2-user/staging /home/ec2-user/.pm2

# TODO: Hardcoded name 'club-xxxx' needs to be picked from terraform.tfvars