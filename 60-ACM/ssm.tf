resource "aws_ssm_parameter" "certificate_arn" {
  name  = "/${var.project_name}/${var.env}/certificate_arn"
  type  = "String"
  value = aws_acm_certificate.main.arn
}
