# Configure the AWS Provider
provider "aws" {
  region = var.region
}

# Use Terraform Cloud Remote Backend to manage state
terraform {
  backend "remote" {
    organization = "32nd"

    workspaces {
      name = "hub-app-backend"
    }
  }
}