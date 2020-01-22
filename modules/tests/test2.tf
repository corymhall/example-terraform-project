resource "aws_ecs_cluster" "terratest" {
  name = "terratest-cluster"
}



module "service" {
  source              = "../ecs_service"
  cluster_arn         = aws_ecs_cluster.terratest.arn
  environment         = "test"
  task_definition_arn = module.task_def.arn
  name                = "terratest"
  project             = "terratest"
}
