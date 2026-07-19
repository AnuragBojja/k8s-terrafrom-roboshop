resource "aws_lb" "ingress-alb" {
  name               = "${local.common_name}-ingress-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [local.ingress_alb_sg_id]
  subnets            = local.public_subnet_ids

  enable_deletion_protection = false

  tags = merge(
    local.common_tags,
    {
        Name = "${local.common_name}-ingress-alb"
    }
    
  )
}

resource "aws_lb_listener" "ingress-alb" {
  load_balancer_arn = aws_lb.ingress-alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-3-2021-06"
  certificate_arn   = local.certificate_arn

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/html"
      message_body = "<h1>Hi! This is ingress alb<h1>"
      status_code  = "200"
    }
  }
}