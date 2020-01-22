provider "aws" {
  region              = local.region
  allowed_account_ids = [local.account_id]
  assume_role {
    role_arn     = "arn:aws:iam::${local.account_id}:role/Terraform"
    session_name = "Terraform"
  }
}

locals {
  env        = split("-", terraform.workspace)[0]
  aws_region = split("-", terraform.workspace)[1]
  region_mapping = {
    useast1 = "us-east-1"
    useast2 = "us-east-2"
  }
  region = local.region_mapping[local.aws_region]
}

variable project {
  type = string
}
