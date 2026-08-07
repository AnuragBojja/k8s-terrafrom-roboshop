# getting roboshop VPC ID from SSM Parameters
data "aws_ssm_parameter" "vpc_id" {
  name = "/${var.project_name}/${var.env}/vpc_id"
}
data "aws_ssm_parameter" "jenkins_agent_sg_id" {
  name = "/${var.project_name}/${var.env}/jenkins_agent_sg_id"
}

data "aws_ssm_parameter" "eks_control_plane_sg_id" {
  name = "/${var.project_name}/${var.env}/eks_control_plane_sg_id"
}

# getting default VPC ID using tags
data "aws_vpc" "default_vpc_id" {
  filter {
    name   = "tag:Name"
    values = ["Default"]
  }
}

# getting default VPC Route Table ID using Tags
data "aws_route_table" "default_vpc_rt" {
  vpc_id = local.default_vpc_id

  tags = {
    Name = "default"
  }
}

data "aws_route_table" "roboshop_vpc_rt" {
  vpc_id = local.roboshop_vpc_id

  tags = {
    Name = "roboshop-dev-private"
  }
}

# extracting Roboshop VPC Data
data "aws_vpc" "roboshop_vpc" {
  id = local.roboshop_vpc_id
}

output "default_vpc_rt" {
  value = data.aws_vpc.default_vpc_id.cidr_block
}