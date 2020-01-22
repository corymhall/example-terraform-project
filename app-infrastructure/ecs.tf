resource "aws_ecs_cluster" "main" {
  name = "${var.project}-${local.env}"
}
