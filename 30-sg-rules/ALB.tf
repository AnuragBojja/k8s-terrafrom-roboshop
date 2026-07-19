################# ingress alb allowing from inter net ###########
resource "aws_security_group_rule" "ingress_alb-internet" {
  type              = "ingress"
  security_group_id = local.ingress_alb_sg_id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
}
