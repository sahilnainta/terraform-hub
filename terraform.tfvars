project             = "club"
region              = "ap-south-1"
key_name            = "club-key"
instance_type       = "t3.medium"
app_hosted_dns      = "32nd.com"
app_dns_prefix      = "api-old.club"
bastion_host_prefix = "bastion.club"
# private_dns     = "app.club"
redis_host_prefix      = "redis.club"
app_min_instance_count = 1
app_max_instance_count = 1
dev_min_instance_count = 1
dev_max_instance_count = 1
app_ami                = "ami-06a3d42ea0fe73a37" // "ami-040704f2452856928" //"ami-0656cd161d1cad375" // "ami-08051fbce9313477a" "ami-08fab01d47695d3ea" // Packer AMI
bastion_ami            = "ami-09c013f43d377d58f"
