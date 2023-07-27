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
# sudo yum -y install gcc make # install GCC compiler
# cd /usr/local/src 
# sudo wget http://download.redis.io/redis-stable.tar.gz
# sudo tar xvzf redis-stable.tar.gz
# sudo rm -f redis-stable.tar.gz
# cd redis-stable
# sudo yum groupinstall "Development Tools"
# sudo make distclean
# sudo make
# sudo yum install -y tcl

# sudo cp src/redis-server /usr/local/bin/
# sudo cp src/redis-cli /usr/local/bin/

# redis-server --daemonize yes

# PM2 config
npm install pm2@latest -g