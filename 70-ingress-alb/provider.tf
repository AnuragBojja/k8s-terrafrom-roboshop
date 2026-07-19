terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
  backend "s3" {
    bucket = "k8s-terrafrom-roboshop"
    key    = "remote-state-k8-roboshop-dev-70-ingress-alb"
    region = "us-east-1"
    use_lockfile = true
    encrypt = true
  }
}

