######################### EKS ###############################
# Eks node allowing all traffic from eks control plane
resource "aws_security_group_rule" "eks_node-eks_control_plane" {
  type              = "ingress"
  security_group_id = local.eks_node_sg_id
  source_security_group_id = local.eks_control_plane_sg_id
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
}
# Eks control plane allowing all traffic from eks node
resource "aws_security_group_rule" "eks_control_plane-eks_node" {
  type              = "ingress"
  security_group_id = local.eks_control_plane_sg_id
  source_security_group_id = local.eks_node_sg_id
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
}

resource "aws_vpc_security_group_ingress_rule" "node-to-node" {
  security_group_id = local.eks_node_sg_id
  referenced_security_group_id = local.eks_node_sg_id
  ip_protocol = "-1"
}