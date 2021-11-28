output "vpc_id" {
  description = "The ID of the main VPC"
  value       = aws_vpc.main.id
}