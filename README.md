# Instructions to Build and Deploy a branch

## One time setup
Download SSH Key - hub-key.pem (request from sahil@32nd.com)
~~~ 
mv ~/Downloads/hub-key.pem ~/.ssh/
chmod 400 ~/.ssh/hub-key.pem
~~~
## Login to Bastion Host
~~~ 
ssh -i ~/.ssh/hub-key.pem ec2-user@bastion.hub.32nd.com
~~~ 

## List app server IP Address for SSH Login
~~~ 
aws ec2 describe-instances \
--query "Reservations[*].Instances[*].{PrivateIP:PrivateIpAddress,Type:InstanceType,Name:Tags[?Key=='Name']|[0].Value,Status:State.Name}"  \
--filters "Name=instance-state-name,Values=running" "Name=tag:Name,Values='hub-app-server'"  \
--output table
~~~ 

## Login to App Server
~~~ 
ssh -i ~/.ssh/hub-key.pem ec2-user@<IP_ADDRESS>
~~~ 

## Go to a envirnoment directory to checkout/pull branch
~~~ 
cd <ENV>/hub-nodejs
~~~ 

## Checkout/Pull branch for deployment
~~~ 
sudo git fetch &&
sudo git checkout master && 
sudo git branch -D <BRANCH_NAME> && 
sudo git checkout <BRANCH_NAME> &&
sudo git pull
~~~ 

## Install new packages
~~~ 
yarn install
~~~ 

## Reload PM2 (Node Process Manager) to apply changes
~~~ 
pm2 reload <ENV>-hub-graphql
~~~ 

## After this new branch shall be live on <env>.api.hub.32nd.com
