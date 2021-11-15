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
cd /home/ec2-user
git clone --depth 1 -b master https://sahilnainta:piertivetechsahikl@bitbucket.org/kundanguesthouser/hub-nodejs.git
cd /home/ec2-user/hub-nodejs
cp .env.example .env

yarn install

sudo touch /etc/nginx/default.d/api.conf
echo 'location /graphql {
                proxy_set_header  X-Real-IP  $remote_addr;
                proxy_set_header  Host       $http_host;
                proxy_pass        http://127.0.0.1:5000;
        }' | sudo tee /etc/nginx/default.d/api.conf

sudo systemctl restart nginx

# node -r esm src/index.js

# PM2 config

yarn global add pm2

# sudo env PATH=$PATH:/home/ec2-user/.nvm/versions/node/v17.1.0/bin /usr/local/share/.config/yarn/global/node_modules/pm2/bin/pm2 startup systemd -u ec2-user --hp /home/ec2-user
PM2_HOME=/home/ec2-user/.pm2 pm2 start src/index.js -i max --node-args="-r esm" --wait-ready --name "hub-graphql"
pm2 save

sudo chown ec2-user:ec2-user /home/ec2-user/.pm2/rpc.sock /home/ec2-user/.pm2/pub.sock