locals {
  common_tags = {
    Project_name = var.project_name
    Env = var.env
    Terraform = "true"
  }
  common_name = ("${var.project_name}-${var.env}")
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  #### ALB ####
  ingress_alb_sg_id = data.aws_ssm_parameter.ingress_alb_sg_id.value
#   backend_alb_sg_id = data.aws_ssm_parameter.backend_alb_sg_id.value
#   frontend_alb_sg_id = data.aws_ssm_parameter.frontend_alb_sg_id.value
  ##### bastion ###
  bastion_sg_id = data.aws_ssm_parameter.bastion_sg_id.value
  ### DATABASES
  mongodb_sg_id = data.aws_ssm_parameter.mongodb_sg_id.value
  rabbitmq_sg_id = data.aws_ssm_parameter.rabbitmq_sg_id.value
  redis_sg_id = data.aws_ssm_parameter.redis_sg_id.value
  mysql_sg_id = data.aws_ssm_parameter.mysql_sg_id.value
  #### EKS ###
  eks_control_plane_sg_id = data.aws_ssm_parameter.eks_control_plane_sg_id.value
  eks_node_sg_id = data.aws_ssm_parameter.eks_node_sg_id.value
  ### frontend####
#   frontend_sg_id = data.aws_ssm_parameter.frontend_sg_id.value

  ####### OPENVPN ############
  openvpn_sg_id = data.aws_ssm_parameter.openvpn_sg_id.value
#   ami_id = data.aws_ami.roboshop_ami.id

#   vpn_ingress_rules_22 = {
#         mysql = {
#             sg_id = local.mysql_sg_id
#         }
#         redis = {
#             sg_id = local.redis_sg_id
#         }
#         mongodb = {
#             sg_id = local.mongodb_sg_id
#         }
#         rabbitmq = {
#             sg_id = local.rabbitmq_sg_id
#         }
#         catalogue = {
#             sg_id = local.catalogue_sg_id
#         }
#         user = {
#             sg_id = local.user_sg_id
#         }
#         cart = {
#             sg_id = local.cart_sg_id
#         }
#         shipping = {
#             sg_id = local.shipping_sg_id
#         }
#         payment = {
#             sg_id = local.payment_sg_id
#         }
#         frontend = {
#             sg_id = local.frontend_sg_id
#         }
#     }

#     vpn_ingress_rules_8080 = {
#         catalogue = {
#             sg_id = local.catalogue_sg_id
#         }
#         user = {
#             sg_id = local.user_sg_id
#         }
#         cart = {
#             sg_id = local.cart_sg_id
#         }
#         shipping = {
#             sg_id = local.shipping_sg_id
#         }
#         payment = {
#             sg_id = local.payment_sg_id
#         }
#     }
#     vpn_ingress_rules_80 = {
#         backend_alb = {
#             sg_id = local.backend_alb_sg_id
#         }
#         frontend_alb = {
#             sg_id = local.frontend_alb_sg_id
#         }
#     }
#     vpn_ingress_rules_databases = {
#         mysql = {
#             sg_id = local.mysql_sg_id
#             port = 3306
#         }
#         redis = {
#             sg_id = local.redis_sg_id
#             port = 6379
#         }
#         mongodb = {
#             sg_id = local.mongodb_sg_id
#             port = 27017
#         }
#         rabbitmq = {
#             sg_id = local.rabbitmq_sg_id
#             port = 5672
#         }
#     }
}
