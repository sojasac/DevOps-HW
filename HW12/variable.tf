variable "aws_region" {
  description = "Регион AWS"
  type        = string
  default     = "us-east-1"
}

variable "ami_id" {
  description = "AMI ID для EC2"
  type        = string
  default     = "ami-0360c520857e3138f"
}

variable "instance_type" {
  description = "Тип инстанса"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "Имя SSH-ключа"
  type        = string
  default     = "devops_september"
}

variable "vpc_cidr" {
  description = "CIDR для VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR для публичной подсети"
  type        = string
  default     = "10.0.1.0/24"
}
