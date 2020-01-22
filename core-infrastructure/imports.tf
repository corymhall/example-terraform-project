data "terraform_remote_state" "meta" {
  backend = "s3"
  config = {
    bucket   = ""
    endpoint = ""
    key      = "terraform-example/meta/terraform.tfstate"
    region   = "us-east-2"
  }
}

locals {
  env        = split("-", terraform.workspace)[0]
  aws_region = split("-", terraform.workspace)[1]
  account_id = data.terraform_remote_state.meta.outputs.env_account_id[local.env]
}
