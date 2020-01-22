module "task_def" {
  source = "../../../ecs_task"

  resource_allocation = "low"
  container_image     = "corymhall/hello-world-go:latest"
  name                = var.name
  environment         = "terratest"
}

module "alb" {
  source = "../../../alb"

  project         = "terratest"
  name            = var.name
  environment     = "terratest"
  certificate_arn = "" // fill this in
}

resource "aws_ecs_cluster" "terratest" {
  name = "${var.name}-cluster"
}

module "service" {
  source                  = "../../../ecs_service"
  cluster_arn             = aws_ecs_cluster.terratest.arn
  environment             = "terratest"
  task_definition_arn     = module.task_def.arn
  name                    = var.name
  project                 = "terratest"
  target_group_arns       = [module.alb.tg_arn]
  ingress_security_groups = [module.alb.security_group_id]
}
