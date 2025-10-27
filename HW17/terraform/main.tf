terraform {
  required_version = ">= 1.2.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.15.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# ---------------------------
# Security Group для нод EKS
# ---------------------------
resource "aws_security_group" "eks_nodes" {
  name        = "${var.cluster_name}-nodes-sg"
  description = "Security group for EKS worker nodes"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow communication within the node group"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  ingress {
    description = "Allow EKS control plane to communicate with worker nodes"
    from_port   = 1025
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.cluster_name}-nodes-sg"
  }
}

# ---------------------------
# Модуль EKS
# ---------------------------
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.6.1"

  name               = var.cluster_name
  kubernetes_version = "1.33" # последняя стабильная версия
  vpc_id             = var.vpc_id
  subnet_ids         = var.private_subnet_ids

  # Добавляем SG для общения control plane ↔ ноды
  node_security_group_additional_rules = {
    ingress_allow_all_from_control_plane = {
      type                         = "ingress"
      protocol                     = "-1"
      from_port                    = 0
      to_port                      = 0
      source_cluster_security_group = true
      description                  = "Allow traffic from EKS control plane"
    }
  }

  eks_managed_node_groups = {
    default = {
      desired_capacity = var.node_desired_capacity
      min_size         = var.node_min_size
      max_size         = var.node_max_size

      instance_types   = [var.node_instance_type]
      ssh_key_name     = var.ssh_key_name
      vpc_security_group_ids = [aws_security_group.eks_nodes.id]

      iam_role_additional_policies = {
        AmazonEKSWorkerNodePolicy          = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
        AmazonEKS_CNI_Policy               = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
        AmazonEC2ContainerRegistryReadOnly = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
      }
    }
  }
}