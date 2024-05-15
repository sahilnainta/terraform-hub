#!/bin/bash

echo "---------- startup script ---------"

sudo su - ec2-user

sudo systemctl start nginx

source /home/ec2-user/.bashrc

# redis-server --daemonize yes

### prod/staging checkout & setup for ELB heartbeat check (Not exposed from outside F.E.)
cd /home/ec2-user
sudo rm -rf prod && mkdir prod
cd /home/ec2-user/prod

# fetch latest tag
latestTag=$(git ls-remote --tags --refs --sort="v:refname" https://32nd-hub-admin:ATBB3x8GXLXgqaNv9TV7MWS66GTSBD45A5F0@bitbucket.org/sahil32nd/hub-nodejs.git | tail -n1 | sed 's/.*\///')

# clone latest tag
git clone --depth 1 -b $latestTag https://32nd-hub-admin:ATBB3x8GXLXgqaNv9TV7MWS66GTSBD45A5F0@bitbucket.org/sahil32nd/hub-nodejs.git

cd hub-nodejs
cp .env.staging .env
echo "" >> .env
echo "APP_PORT=5000" >> .env
echo "APP_ENV=staging0" >> .env

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
git clone -b master https://32nd-hub-admin:ATBB3x8GXLXgqaNv9TV7MWS66GTSBD45A5F0@bitbucket.org/sahil32nd/hub-nodejs.git
cd hub-nodejs
yarn install
yarn build


# start staging1 PM2
cd /home/ec2-user
sudo rm -rf staging1 && cp -R club-app staging1
cd /home/ec2-user/staging1/hub-nodejs
cp .env.staging .env
echo "" >> .env
echo "APP_PORT=6001" >> .env
echo "APP_ENV=staging1" >> .env

stag="staging1-club-graphql"
PM2_HOME=/home/ec2-user/.pm2 pm2 start build/index.js -i max --wait-ready --name $stag
pm2 save

# start qa PM2
cd /home/ec2-user
sudo rm -rf qa && cp -R club-app qa
cd /home/ec2-user/qa/hub-nodejs
cp .env.qa .env

qa="qa-club-graphql"
PM2_HOME=/home/ec2-user/.pm2 pm2 start build/index.js -i max --wait-ready --name $qa
pm2 save

# start qa1 PM2
cd /home/ec2-user
sudo rm -rf qa1 && cp -R qa qa1
cd /home/ec2-user/qa1/hub-nodejs
echo "" >> .env
echo "APP_PORT=7001" >> .env
echo "APP_ENV=qa1" >> .env

stag="qa1-club-graphql"
PM2_HOME=/home/ec2-user/.pm2 pm2 start build/index.js -i max --wait-ready --name $stag
pm2 save

# start dev PM2
cd /home/ec2-user
sudo rm -rf dev && cp -R club-app dev
cd /home/ec2-user/dev/hub-nodejs
cp .env.dev .env

dev="dev-club-graphql"
PM2_HOME=/home/ec2-user/.pm2 pm2 start build/index.js -i max --wait-ready --name $dev
pm2 save

# start dev1 PM2
cd /home/ec2-user
sudo rm -rf dev1 && cp -R dev dev1
cd /home/ec2-user/dev1/hub-nodejs
echo "" >> .env
echo "APP_PORT=8001" >> .env
echo "APP_ENV=dev1" >> .env

stag="dev1-club-graphql"
PM2_HOME=/home/ec2-user/.pm2 pm2 start build/index.js -i max --wait-ready --name $stag
pm2 save

# start analytics PM2
cd /home/ec2-user
sudo rm -rf analytics && cp -R dev analytics
cd /home/ec2-user/analytics/hub-nodejs
echo "" >> .env
echo "APP_PORT=9001" >> .env
echo "APP_ENV=analytics" >> .env

stag="analytics-club-graphql"
PM2_HOME=/home/ec2-user/.pm2 pm2 start build/index.js -i max --wait-ready --name $stag
pm2 save

## Removing developer envirnoment directory 
cd /home/ec2-user
sudo rm -rf club-app

# sudo chown ec2-user:ec2-user /home/ec2-user/.pm2/rpc.sock /home/ec2-user/.pm2/pub.sock
sudo chown ec2-user:ec2-user /home/ec2-user/.pm2/rpc.sock /home/ec2-user/.pm2/pub.sock /home/ec2-user/.pm2/reload.lock
# yarn install from ec2-user & PM2 logging
sudo chown -R ec2-user /home/ec2-user/prod /home/ec2-user/qa /home/ec2-user/dev /home/ec2-user/.pm2

sudo chown -R ec2-user /home/ec2-user/staging1 /home/ec2-user/qa1 /home/ec2-user/dev1 /home/ec2-user/analytics
# TODO: Hardcoded name 'club-xxxx' needs to be picked from terraform.tfvars