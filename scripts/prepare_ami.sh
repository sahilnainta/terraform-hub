#!/bin/bash

sudo su - ec2-user

sudo yum install git -y

sudo yum install amazon-cloudwatch-agent -y

# ssm parameter name for cloudwatch agent config file is hardcoded - club-cwagent-config
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c ssm:club-cwagent-config

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

# nvm install node
nvm install 16
npm install -g yarn

sudo amazon-linux-extras list | grep nginx
sudo amazon-linux-extras enable nginx1
sudo yum clean metadata
sudo yum -y install nginx

sudo systemctl start nginx

# nginx configuration
sudo touch /etc/nginx/conf.d/server.conf
echo  'server {
  server_name api.club.32nd.com;
  location /graphql {
      proxy_set_header  X-Real-IP  $remote_addr;
      proxy_set_header  Host       $http_host;
      proxy_pass        http://127.0.0.1:5000;

      # Websocket
      proxy_http_version 1.1;
      proxy_set_header Upgrade $http_upgrade;
      proxy_set_header Connection "upgrade";
    }

  location /rest {
      proxy_set_header  X-Real-IP  $remote_addr;
      proxy_set_header  Host       $http_host;
      proxy_pass        http://127.0.0.1:5000;
    }
}
server {
  server_name staging.api.club.32nd.com;
  location /graphql {
      proxy_set_header  X-Real-IP  $remote_addr;
      proxy_set_header  Host       $http_host;
      proxy_pass        http://127.0.0.1:6000;

      # Websocket
      proxy_http_version 1.1;
      proxy_set_header Upgrade $http_upgrade;
      proxy_set_header Connection "upgrade";
    }

  location /rest {
      proxy_set_header  X-Real-IP  $remote_addr;
      proxy_set_header  Host       $http_host;
      proxy_pass        http://127.0.0.1:6000;
    }
}
server {
  server_name qa.api.club.32nd.com;
  location /graphql {
      proxy_set_header  X-Real-IP  $remote_addr;
      proxy_set_header  Host       $http_host;
      proxy_pass        http://127.0.0.1:7000;
      
      # Websocket
      proxy_http_version 1.1;
      proxy_set_header Upgrade $http_upgrade;
      proxy_set_header Connection "upgrade";
    }

  location /rest {
      proxy_set_header  X-Real-IP  $remote_addr;
      proxy_set_header  Host       $http_host;
      proxy_pass        http://127.0.0.1:7000;
    }
}
server {
  server_name dev.api.club.32nd.com;
  location /graphql {
      proxy_set_header  X-Real-IP  $remote_addr;
      proxy_set_header  Host       $http_host;
      proxy_pass        http://127.0.0.1:8000;

      # Websocket
      proxy_http_version 1.1;
      proxy_set_header Upgrade $http_upgrade;
      proxy_set_header Connection "upgrade";
    }

  location /rest {
      proxy_set_header  X-Real-IP  $remote_addr;
      proxy_set_header  Host       $http_host;
      proxy_pass        http://127.0.0.1:8000;
    }
}' | sudo tee /etc/nginx/conf.d/server.conf

sudo systemctl restart nginx

#### Install Redis
sudo yum -y install gcc make # install GCC compiler
cd /usr/local/src 
sudo wget http://download.redis.io/redis-stable.tar.gz
sudo tar xvzf redis-stable.tar.gz
sudo rm -f redis-stable.tar.gz
cd redis-stable
sudo yum groupinstall "Development Tools"
sudo make distclean
sudo make
sudo yum install -y tcl

# sudo make test

sudo cp src/redis-server /usr/local/bin/
sudo cp src/redis-cli /usr/local/bin/

redis-server --daemonize yes

# PM2 config
yarn global add pm2

# prod checkout & setup
cd /home/ec2-user
mkdir prod
cd /home/ec2-user/prod

# fetch latest tag
latestTag=$(git ls-remote --tags --refs --sort="v:refname" https://32nd-hub-admin:ATBB3x8GXLXgqaNv9TV7MWS66GTSBD45A5F0@bitbucket.org/sahil32nd/hub-nodejs.git | tail -n1 | sed 's/.*\///')

# clone latest tag
git clone --depth 1 -b $latestTag https://32nd-hub-admin:ATBB3x8GXLXgqaNv9TV7MWS66GTSBD45A5F0@bitbucket.org/sahil32nd/hub-nodejs.git

cd hub-nodejs
cp .env.production .env

yarn install

# start production PM2
prod="prod-club-graphql"
cd /home/ec2-user/prod/hub-nodejs
PM2_HOME=/home/ec2-user/.pm2 pm2 start src/index.js -i max --node-args="-r esm" --wait-ready --name $prod
pm2 save

### staging checkout & setup
cd /home/ec2-user
mkdir staging
cd /home/ec2-user/staging

git clone -b master https://32nd-hub-admin:ATBB3x8GXLXgqaNv9TV7MWS66GTSBD45A5F0@bitbucket.org/sahil32nd/hub-nodejs.git
cd hub-nodejs
cp .env.staging .env

yarn install

# start staging PM2
stag="staging-club-graphql"
cd /home/ec2-user/staging/hub-nodejs
PM2_HOME=/home/ec2-user/.pm2 pm2 start src/index.js -i max --node-args="-r esm" --wait-ready --name $stag
pm2 save


### qa checkout & setup
cd /home/ec2-user
mkdir qa
cd /home/ec2-user/qa

git clone -b master https://32nd-hub-admin:ATBB3x8GXLXgqaNv9TV7MWS66GTSBD45A5F0@bitbucket.org/sahil32nd/hub-nodejs.git
cd hub-nodejs
cp .env.qa .env

yarn install

# start qa PM2
qa="qa-club-graphql"
cd /home/ec2-user/qa/hub-nodejs
PM2_HOME=/home/ec2-user/.pm2 pm2 start src/index.js -i max --node-args="-r esm" --wait-ready --name $qa
pm2 save

### dev checkout & setup
cd /home/ec2-user
mkdir dev
cd /home/ec2-user/dev

git clone -b master https://32nd-hub-admin:ATBB3x8GXLXgqaNv9TV7MWS66GTSBD45A5F0@bitbucket.org/sahil32nd/hub-nodejs.git
cd hub-nodejs
cp .env.dev .env

yarn install

# start dev PM2
dev="dev-club-graphql"
cd /home/ec2-user/dev/hub-nodejs
PM2_HOME=/home/ec2-user/.pm2 pm2 start src/index.js -i max --node-args="-r esm" --wait-ready --name $dev
pm2 save

# sudo chown ec2-user:ec2-user /home/ec2-user/.pm2/rpc.sock /home/ec2-user/.pm2/pub.sock
sudo chown ec2-user:ec2-user /home/ec2-user/.pm2/rpc.sock /home/ec2-user/.pm2/pub.sock /home/ec2-user/.pm2/reload.lock
# yarn install from ec2-user & PM2 logging
sudo chown -R ec2-user /home/ec2-user/prod /home/ec2-user/staging /home/ec2-user/qa /home/ec2-user/dev /home/ec2-user/.pm2