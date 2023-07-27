# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

packer {
  required_plugins {
    amazon = {
      version = " >= 1.2.6"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "region" {
  type    = string
  default = "ap-south-1"
}

locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }


# source blocks are generated from your builders; a source can be referenced in
# build blocks. A build block runs provisioners and post-processors on a
# source.

source "amazon-ebs" "club-app" {
  ami_name      = "club-app-server-${local.timestamp}"
  instance_type = "t3.medium"
  region        = var.region
  # source_ami    = "ami-0770726357cfe8240"
  source_ami_filter {
    filters = {
      name                = "amzn2-ami-hvm-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["amazon"]
  }
  ssh_username   = "ec2-user"
  tags = {
    Project = "club-app"
    Name    = "club-app-server"
  }
}

# a build block invokes sources and runs provisioning steps on them.
build {
  name = "club-app-server"
  sources = ["source.amazon-ebs.club-app"]

  provisioner "shell" {
    script = "../scripts/prepare_ami.sh"
    # inline = [
    #   "pwd",
    # ]
  }

}
