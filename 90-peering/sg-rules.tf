resource "aws_vpc_security_group_ingress_rule" "jenkins_agent-eks_control_plane" {
  security_group_id = local.eks_control_plane_sg_id

  referenced_security_group_id   = local.jenkins_agent_sg_id
  from_port   = 443
  ip_protocol = "tcp"
  to_port     = 443
}