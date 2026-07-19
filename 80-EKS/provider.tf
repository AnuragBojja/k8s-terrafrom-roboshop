terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.52"
    }
  }
  backend "s3" {
    bucket = "k8s-terrafrom-roboshop"
    key    = "remote-state-k8-roboshop-dev-80-EKS"
    region = "us-east-1"
    use_lockfile = true
    encrypt = true
  }
}

