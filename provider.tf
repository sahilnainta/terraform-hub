# Specify versions of providers
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.region
  // TODO: Somehow ~/.aws/credentails not working.
    # access_key = "AKIAQBSFXYZ432XS4Y3G"
    # secret_key = "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"

}

# Use Terraform Cloud Remote Backend to manage state
terraform {
  backend "remote" {
    organization = "32nd"

    workspaces {
      name = "club-app-backend"
    }
  }
}

// TODO: Workspace Name & Org Name 'club-xxx' shouldn't be hardcoded, should be picked from terraform.tfvars