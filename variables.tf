variable "project" {
  description = "Project Name"
  type = string
  default = "hub-app"
}
variable "region" {
  description = "AWS Region"
  type = string
  default = "us-west-1"
}

variable "az" {
  description = "Availability Zone"
  type = string
  default = "us-west-1a"
}

variable "instance_type" {
  description = "Instance Type"
  type = string
  default = "t2.micro"
}

variable "instance_count" {
  description = "Instance Count"
  type = string
  default = 1
}

variable "key_name" {
  description = "Key Name"
  type = string
  default = "hub_app_key"
}
