output "aws_lb_target_group_arn" {
    description = "ALB target group ARN"
    value = aws_lb_target_group.ecs_nginx_webapp.arn
}

output "alb_security_group_id" {
    description = "ALB target group ARN"
    value = aws_security_group.alb_sg.id
}
