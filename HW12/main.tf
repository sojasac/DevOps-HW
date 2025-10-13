provider "aws" {
  region = var.aws_region
}

resource "aws_instance" "sergeyp_instance" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name = var.key_name
  subnet_id = aws_subnet.sergeyp_public_subnet.id
  vpc_security_group_ids = [aws_security_group.sergeyp_sg.id]

}

resource "aws_security_group" "sergeyp_sg" {
  name        = "sergeyp-sg"
  description = "SG"
  vpc_id = aws_vpc.sergeyp_vpc.id
 
  ingress {
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_vpc" "sergeyp_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "sergeyp-vpc"
  }
}

resource "aws_internet_gateway" "sergeyp_igw" {
  vpc_id = aws_vpc.sergeyp_vpc.id
  tags = {
    Name = "sergeyp-igw"
  }
}

resource "aws_subnet" "sergeyp_public_subnet" {
  vpc_id                  = aws_vpc.sergeyp_vpc.id
  cidr_block              = var.subnet_cidr
  map_public_ip_on_launch = true
  tags = {
    Name = "sergeyp_public_subnet"
  }
}

resource "aws_route_table" "sergeyp_public_rt" {
  vpc_id = aws_vpc.sergeyp_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.sergeyp_igw.id
  }
  tags = {
    Name = "sergeyp_public-rt"
  }
}
