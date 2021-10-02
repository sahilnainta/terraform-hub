variable "project" {
  description = "Project Name"
  type = string
  default = "terraform-project"
}
variable "region" {
  description = "AWS Region"
  type = string
  default = "us-west-1"
}

variable "instance_type" {
  description = "Instance Type"
  type = string
  default = "t2.micro"
}

variable "app_instance_count" {
  description = "Instance Count"
  type = string
  default = 1
}

variable "key_name" {
  description = "Key Name"
  type = string
  default = "terraform-app-key"
}

variable "ami" {
  description = "AMI"
  type = string
  default = "ami-0c473704d15f7317c"
}
