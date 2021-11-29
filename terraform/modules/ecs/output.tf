output "ecs_cluster" {
  value = aws_ecs_cluster.webapps_cluster
}

output "ecs_service" {
  value = aws_ecs_service.nginx_webapp
}