output "instance_id" {
  value = aws_instance.sergeyp_instance.id
}

output "instance_public_ip" {
  value = aws_instance.sergeyp_instance.public_ip
}

output "vpc_id" {
  value = aws_vpc.sergeyp_vpc.id
}