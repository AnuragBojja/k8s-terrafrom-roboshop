module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = "${local.common_name}-EKS"
  kubernetes_version = var.EKS_version

  addons = {
    coredns                = {}
    eks-pod-identity-agent = {
      before_compute = true
    }
    kube-proxy             = {}
    vpc-cni                = {
      before_compute = true
    }
    metrics-server = {}
  }

  # Optional
  endpoint_public_access = false

  # Optional: Adds the current caller identity as an administrator via cluster access entry
  enable_cluster_creator_admin_permissions = true

  vpc_id                   = local.vpc_id
  subnet_ids               = local.private_subnet_ids
  control_plane_subnet_ids = local.private_subnet_ids
  create_node_security_group = false
  node_security_group_id = local.eks_node_sg_id
  node_security_group_description = "EKS node shared security group"
  create_security_group = false
  security_group_id = local.eks_control_plane_sg_id
  security_group_description = "EKS cluster security group"

  # EKS Managed Node Group(s)
  eks_managed_node_groups = {
    blue = {
      # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
      create = var.create_blue
      ami_type       = "AL2023_x86_64_STANDARD"
      kubernetes_version = var.EKS_nodegroup_blue_version
      instance_types = ["m5.xlarge"]
      
      iam_role_additional_policies = {
          AmazonEBSDriver = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
          AmazonEFSDriver = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
      }
      min_size     = 2
      max_size     = 10
      desired_size = 2
      labels = {
          nodegroup = "blue"
      }
    }
    
    green = {
      # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
      create = var.create_green
      ami_type       = "AL2023_x86_64_STANDARD"
      kubernetes_version = var.EKS_nodegroup_green_version
      instance_types = ["m5.xlarge"]
      
      iam_role_additional_policies = {
          AmazonEBSDriver = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
          AmazonEFSDriver = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
      }
      min_size     = 2
      max_size     = 10
      desired_size = 2
      labels = {
          nodegroup = "green"
      }   
    }

  }

  tags = merge(
    local.common_tags,
    {
        Name = "${local.common_name}-EKS"
    }
  )
}