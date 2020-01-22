terraform {
  backend "s3" {
    bucket   = ""
    endpoint = ""
    key      = "terraform-example/core/terraform.tfstate"
    region   = "us-east-2"
  }
}
