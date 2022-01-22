#!/bin/bash

sudo su - ec2-user

sudo yum install git -y

export NVM_DIR="/home/ec2-user/.nvm" && (
  git clone https://github.com/nvm-sh/nvm.git "$NVM_DIR"
  cd "$NVM_DIR"
  git checkout `git describe --abbrev=0 --tags --match "v[0-9]*" $(git rev-list --tags --max-count=1)`
) && \. "$NVM_DIR/nvm.sh"

echo 'export NVM_DIR="/home/ec2-user/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion' | sudo tee -a /home/ec2-user/.bashrc

source /home/ec2-user/.bashrc

cd /home/ec2-user

nvm install node
npm install -g yarn

sudo amazon-linux-extras list | grep nginx
sudo amazon-linux-extras enable nginx1
sudo yum clean metadata
sudo yum -y install nginx

sudo systemctl start nginx

# prod checkout & setup
cd /home/ec2-user
mkdir prod
cd /home/ec2-user/prod

git clone --depth 1 -b master https://sahilnainta:sahil32nd@bitbucket.org/vikas_gh/hub-nodejs.git
cd hub-nodejs
cp .env.production .env

yarn install

# staging checkout & setup
cd /home/ec2-user
mkdir staging
cd /home/ec2-user/staging

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

# nginx configuration
sudo touch /etc/nginx/conf.d/server.conf
echo  'server {
  server_name staging.api.hub.32nd.com;
  location /graphql {
      proxy_set_header  X-Real-IP  $remote_addr;
      proxy_set_header  Host       $http_host;
      proxy_pass        http://127.0.0.1:6000;
    }
}
server {
  server_name qa.api.hub.32nd.com;
  location /graphql {
      proxy_set_header  X-Real-IP  $remote_addr;
      proxy_set_header  Host       $http_host;
      proxy_pass        http://127.0.0.1:7000;
    }
}
server {
  server_name dev.api.hub.32nd.com;
  location /graphql {
      proxy_set_header  X-Real-IP  $remote_addr;
      proxy_set_header  Host       $http_host;
      proxy_pass        http://127.0.0.1:8000;
    }
}
server {
  server_name api.hub.32nd.com;
  location /graphql {
      proxy_set_header  X-Real-IP  $remote_addr;
      proxy_set_header  Host       $http_host;
      proxy_pass        http://127.0.0.1:5000;
    }
}' | sudo tee /etc/nginx/conf.d/server.conf

sudo systemctl restart nginx

# PM2 config
yarn global add pm2

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