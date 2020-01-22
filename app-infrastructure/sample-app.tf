locals {
  resource_allocation = {
    dev = "low"
    prd = "high"
  }
}
module "sample-app_task_def" {
  source = "../modules/ecs_task"

  resource_allocation = local.resource_allocation[local.env]
  container_image     = "corymhall/hello-world-go:latest"
  name                = "sample-app"
  environment         = local.env
}

module "sample-app_s3_iam" {
  source = "../modules/s3-iam"

  role         = module.sample-app_task_def.execution_role
  access_level = ["read"]
  bucket       = "my-sample-bucket"
}

module "sample-app_alb" {
  source = "../modules/alb"

  project         = var.project
  name            = "sample-app"
  environment     = local.env
  certificate_arn = local.example_com_cert
}

module "sample-app_ecs_service" {
  source                  = "../modules/ecs_service"
  cluster_arn             = aws_ecs_cluster.main.arn
  environment             = local.env
  task_definition_arn     = module.sample-app_task_def.arn
  name                    = "sample-app"
  project                 = var.project
  target_group_arns       = [module.sample-app_alb.tg_arn]
  ingress_security_groups = [module.sample-app_alb.security_group_id]
}
