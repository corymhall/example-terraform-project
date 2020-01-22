locals {
  cidr_blocks = {
    prd    = "10.6.0.0/16"
    nonprd = "10.8.0.0/16"
  }
}
module "subnets" {
  source          = "hashicorp/subnets/cidr"
  version         = "1.0.0"
  base_cidr_block = local.cidr_blocks[local.env]
  networks = [
    {
      name     = "private-a"
      new_bits = 4
    },
    {
      name     = "public-a"
      new_bits = 4
    },
    {
      name     = "database-a"
      new_bits = 4
    },
    {
      name     = "private-b"
      new_bits = 4
    },
    {
      name     = "public-b"
      new_bits = 4
    },
    {
      name     = "database-b"
      new_bits = 4
    },
    {
      name     = "private-c"
      new_bits = 4
    },
    {
      name     = "public-c"
      new_bits = 4
    },
    {
      name     = "database-c"
      new_bits = 4
    },
  ]
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.21.0"

  name = "${var.project}_${local.env}"
  cidr = module.subnets.base_cidr_block

  azs                   = ["${local.region}a", "${local.region}b", "${local.region}c"]
  private_subnets       = [module.subnets.network_cidr_blocks["private-a"], module.subnets.network_cidr_blocks["private-b"], module.subnets.network_cidr_blocks["private-c"]]
  private_subnet_suffix = "app"
  private_subnet_tags = {
    "subnet-type" = "app"
  }

  public_subnets       = [module.subnets.network_cidr_blocks["public-a"], module.subnets.network_cidr_blocks["public-b"], module.subnets.network_cidr_blocks["public-c"]]
  public_subnet_suffix = "dmz"
  public_subnet_tags = {
    "subnet-type" = "dmz"
  }

  database_subnets       = [module.subnets.network_cidr_blocks["database-a"], module.subnets.network_cidr_blocks["database-b"], module.subnets.network_cidr_blocks["database-c"]]
  database_subnet_suffix = "db"
  database_subnet_tags = {
    "subnet-type" = "db"
  }

  single_nat_gateway = true

  tags = {
    environment   = local.env
    provisioner   = "Terraform"
    (var.project) = "true"
  }
}
