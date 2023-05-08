variable "project" {
  description = "Project Name"
  type        = string
  default     = "terraform"
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
  default     = "test.com"
}

variable "app_dns_prefix" {
  description = "App DNS prefix"
  type        = string
  default     = "app.terraform"
}

variable "bastion_host_prefix" {
  description = "Bastion DNS prefix"
  type        = string
  default     = "bastion.terraform"
}

variable "private_dns" {
  description = "Route53 Hosted Zone Name"
  type        = string
  default     = "app.terraform"
}

variable "redis_host_prefix" {
  description = "Redis DNS prefix"
  type        = string
  default     = "redis"
}

variable "app_instance_count" {
  description = "Instance Count"
  type        = string
  default     = 1 // Change this to 2 for production
}

variable "key_name" {
  description = "Key Name"
  type        = string
  default     = "terraform-app-key"
}

variable "app_ami" {
  description = "AMI"
  type        = string
  default     = ""
}

variable "bastion_ami" {
  description = "AMI"
  type        = string
  default     = ""
}
