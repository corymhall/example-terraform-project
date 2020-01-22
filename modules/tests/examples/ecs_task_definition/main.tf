resource "aws_ecr_repository" "test" {
  name = lower(var.name)
}

module "task_def" {
  source = "../../../ecs_task"

  resource_allocation = var.resource_allocation
  container_image     = "hello-world:latest"
  name                = var.name
  fargate             = var.fargate
  network_mode        = var.network_mode
  environment         = "terratest"
  cpu                 = var.cpu
  memory              = var.memory
  port_mappings       = var.port_mappings
  ecr_repos           = [aws_ecr_repository.test.arn]
}
