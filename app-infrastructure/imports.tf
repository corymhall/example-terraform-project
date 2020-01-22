locals {
  global_state_keys = {
    prd = "env:/prd-useast2/terraform-example/core/terraform.tfstate"
    dev = "env:/nonprd-useast2/terraform-example/core/terraform.tfstate"
  }
  regional_state_keys = {
    prd = "env:/prd-${local.aws_region}/terraform-example/core/terraform.tfstate"
    dev = "env:/nonprd-${local.aws_region}/terraform-example/core/terraform.tfstate"

  }
}

data "terraform_remote_state" "global" {
  backend = "s3"
  config = {
    bucket   = ""
    endpoint = ""
    key      = local.global_state_keys[local.env]
    region   = "us-east-2"
  }
}

data "terraform_remote_state" "regional" {
  backend = "s3"
  config = {
    bucket   = ""
    endpoint = ""
    key      = local.regional_state_keys[local.env]
    region   = "us-east-2"
  }
}

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
  account_id       = data.terraform_remote_state.meta.outputs.env_account_id[local.env]
  example_com_cert = data.terraform_remote_state.regional.outputs.example_com_cert
}
