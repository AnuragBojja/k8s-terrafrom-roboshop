resource "aws_ssm_parameter" "ingress_alb_listener_arn" {
  name  = "/${var.project_name}/${var.env}/ingress_alb_listener_arn"
  type  = "StringList"
  value = aws_lb_listener.ingress-alb.arn
}