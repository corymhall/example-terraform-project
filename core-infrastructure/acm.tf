data "aws_acm_certificate" "cert" {
  domain   = local.env == "nonprd" ? "*.mb-dev.${var.domain}" : "*.mb-prod.${var.domain}"
  statuses = ["ISSUED"]
}
