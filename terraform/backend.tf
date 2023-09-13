terraform {
  backend "s3" {
    bucket = "terraform-state-upgrad"
    key    = "terraform-upgrad.tfstate"
    region = "us-east-1"
  }
}
