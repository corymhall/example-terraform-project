variable resource_allocation {
  type    = string
  default = "low"
}

variable name {
  type = string
}

variable fargate {
  type    = bool
  default = true
}

variable network_mode {
  type    = string
  default = "awsvpc"
}

variable cpu {
  type    = number
  default = null
}

variable memory {
  type    = number
  default = null
}

variable port_mappings {
  type = list(object({
    containerPort = number
    hostPort      = number
    protocol      = string
  }))
  default = [
    {
      containerPort = 3000
      hostPort      = 3000
      protocol      = "tcp"
    }
  ]
}

variable task_role_arn {
  type    = string
  default = ""
}
