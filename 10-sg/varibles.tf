variable "env" {
  default = "dev"
}
variable "project_name" {
  default = "roboshop"
}
variable "sg_names" {
  default = [
    #databases
    "mongodb","redis","rabbitmq","mysql",
    #bastion_host
    "bastion",
    #OpenVPN
    "openvpn",
    #load Balancers
    "ingress_alb",
    #EKS 
    "eks_control_plane","eks_node"
    ]
}
