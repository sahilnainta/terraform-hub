variable "project" {
  description = "Project Name"
  type        = string
  default     = "terraform-project"
}
variable "region" {
  description = "AWS Region"
  type        = string
  default     = "us-west-1"
}

variable "instance_type" {
  description = "Instance Type"
  type        = string
  default     = "t2.micro"
}

variable "app_hosted_dns" {
  description = "Route53 Hosted Zone Name"
  type        = string
  default     = "32nd.com"
}

variable "app_dns_prefix" {
  description = "App DNS prefix"
  type        = string
  default     = "api.hub"
}

variable "bastion_host_prefix" {
  description = "Bastion DNS prefix"
  type        = string
  default     = "bastion.hub"
}

variable "app_instance_count" {
  description = "Instance Count"
  type        = string
  default     = 2
}

variable "key_name" {
  description = "Key Name"
  type        = string
  default     = "terraform-app-key"
}

# variable "ami" {
#   description = "AMI"
#   type        = string
#   default     = "ami-0c473704d15f7317c"
# }
