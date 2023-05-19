# Use Terraform Cloud Remote Backend to manage state
terraform {
  backend "remote" {
    organization = "32nd"

    workspaces {
      name = "club-app-backend"
    }
  }
}