variable network_lb_health_check {
  type = list(object({
    enabled             = bool
    interval            = number
    port                = string
    protocol            = string
    healthy_threshold   = number
    unhealthy_threshold = number
  }))
  default = [{
    enabled             = true
    interval            = 30
    port                = "traffic-port"
    protocol            = "TCP"
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }]
}

variable application_lb_health_check {
  type = list(object({
    enabled             = bool
    interval            = number
    port                = string
    path                = string
    protocol            = string
    healthy_threshold   = number
    unhealthy_threshold = number
    matcher             = string
  }))
  default = [{
    enabled             = true
    interval            = 30
    port                = "traffic-port"
    path                = "/ping"
    protocol            = "HTTP"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200,299"
  }]
}

variable name {
  type = string
}

variable load_balancer_type {
  type    = string
  default = "application"
}

variable internal {
  type    = bool
  default = false
}

variable application_port {
  type    = number
  default = 3000
}

variable target_type {
  type    = string
  default = "ip"
}
