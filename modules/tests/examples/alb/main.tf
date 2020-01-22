module "alb" {
  source = "../../../alb"

  project            = "terratest"
  name               = var.name
  environment        = "terratest"
  certificate_arn    = "" // fill this in
  load_balancer_type = var.load_balancer_type
  internal           = var.internal
  application_port   = var.application_port
  target_type        = var.target_type
}
