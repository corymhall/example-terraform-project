output alb_url {
  value = module.alb.lb_url
}

output cluster_name {
  value = "${var.name}-cluster"
}

output service_name {
  value = module.service.service_name
}
