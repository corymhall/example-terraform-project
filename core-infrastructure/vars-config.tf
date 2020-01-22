provider "aws" {
  region              = local.region
  allowed_account_ids = [local.account_id]

  // I am running terraform from a central account with a role that has access to the central state bucket through
  // s3 access points and has access to assume a Terraform role in each account to create the infrastructure
  assume_role {
    role_arn     = "arn:aws:iam::${local.account_id}:role/Terraform"
    session_name = "Terraform"
  }
}

locals {
  global_workspaces = ["prd-useast2", "nonprd-useast2"]
  region_mapping = {
    useast1 = "us-east-1"
    useast2 = "us-east-2"
  }
  region    = local.region_mapping[local.aws_region]
  is_global = contains(local.global_workspaces, terraform.workspace)
}

variable project {
  type = string
}

variable domain {
  type = string
}
