# Instructions to Build and Deploy a branch

## One time setup
Download SSH Key - club-key.pem (request from sahil@32nd.com)
~~~ 
mv ~/Downloads/club-key.pem ~/.ssh/
chmod 400 ~/.ssh/club-key.pem
~~~
## Login to Bastion Host
~~~ 
ssh -i ~/.ssh/club-key.pem ec2-user@bastion.club.32nd.com
~~~ 

## List app server IP Address for SSH Login
~~~ 
aws ec2 describe-instances \
--query "Reservations[*].Instances[*].{PrivateIP:PrivateIpAddress,Type:InstanceType,Name:Tags[?Key=='Name']|[0].Value,Status:State.Name}"  \
--filters "Name=instance-state-name,Values=running" "Name=tag:Name,Values='club-app-server'"  \
--output table
~~~ 

## Login to App Server
~~~ 
ssh -i ~/.ssh/club-key.pem ec2-user@<IP_ADDRESS>
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
pm2 reload <ENV>-club-graphql
~~~ 

## After this new branch shall be live on <env>.api.club.32nd.com


# Instructions to setup terraform (Frist time setup only)
DO NOT REPEAT FOLLOWING STEPS, ONLY MEANT FOR FIRST TIME SETUP

1. Delete .terraform/* & ~/.ssh
2. terraform init
3. Setup AWS CLI & Add AWS credentials in ~/.aws/credentials
4. Connect to a remote backend by setting up a project on terraform cloud with remote execution set to loacal and use the same configuration in provider.tf
5. Make changes to terraform.tfvars and run following -
~~~
terraform plan
terraform apply
~~~
6. Copy generated pem file to ~/.ssh path
~~~ 
mv ~/Downloads/club-key.pem ~/.ssh/
chmod 400 ~/.ssh/club-key.pem
~~~

# Instructions to build app-server image with Packer

# Install Packer 
brew tap hashicorp/tap
brew install hashicorp/tap/packer

1. cd <PROJECT_DIR>/packer
2. packer init
3. packer build .
   
AMI ID will be returned if all steps ran sucessfully.




