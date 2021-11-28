output "aws_lb_target_group_arn" {
    description = "ALB target group ARN"
    value = aws_lb_target_group.ecs_nginx_webapp.arn
}
