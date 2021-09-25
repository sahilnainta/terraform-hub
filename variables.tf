variable "project" {
  description = "Project Name"
  type = string
  default = "hub-app"
}
variable "region" {
  description = "AWS Region"
  type = string
  default = "us-east-1"
}

variable "az" {
  description = "Availability Zone"
  type = string
  default = "us-east-1a"
}

variable "instance_type" {
  description = "Instance Type"
  type = string
  default = "t2.micro"
}

variable "key_name" {
  description = "Key Name"
  type = string
  default = "hub_app_key"
}
