terraform {
  required_version = ">= 0.12"
  backend "s3" {
    bucket       = "tf-state-bucket-kuseh-101"
    key          = "dev/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}