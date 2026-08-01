variable "env" {
  default = "dev"
}
variable "project_name" {
  default = "roboshop"
}

variable "service" {
  default = ["catalogue","user","cart","shipping","payment","frontend"]
}