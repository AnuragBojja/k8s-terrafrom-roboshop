locals {
  common_tags = {
    Project_name = var.project_name
    Env = var.env
    Terraform = "true"
  }
  common_name = ("${var.project_name}-${var.env}")
  roboshop_vpc_id = data.aws_ssm_parameter.vpc_id.value
  default_vpc_id = data.aws_vpc.default_vpc_id.id
  default_vpc_rt_id = data.aws_route_table.default_vpc_rt.id
  roboshop_vpc_rt_id = data.aws_route_table.roboshop_vpc_rt.id
  default_vpc_cidr = data.aws_vpc.default_vpc_id.cidr_block
  roboshop_vpc_cidr = data.aws_vpc.roboshop_vpc.cidr_block
  jenkins_agent_sg_id = data.aws_ssm_parameter.jenkins_agent_sg_id.value
  eks_control_plane_sg_id = data.aws_ssm_parameter.eks_control_plane_sg_id.value
}