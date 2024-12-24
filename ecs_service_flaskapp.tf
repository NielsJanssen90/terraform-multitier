resource "aws_ecs_service" "flaskapp" {
  name            = "FlaskApp-Service"
  cluster         = aws_ecs_cluster.web-cluster.arn
  task_definition = aws_ecs_task_definition.FlaskApp.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [aws_subnet.private_a.id, aws_subnet.private_b.id]  
    security_groups = [aws_security_group.http.id]  
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.flaskapp-tg.arn  
    container_name   = "FlaskApp"
    container_port   = 80
  }

  deployment_controller {
    type = "ECS"
  }

  lifecycle {
    ignore_changes = [desired_count]  # Prevents Terraform from modifying the desired count
  }

  depends_on = [
    aws_lb_target_group.flaskapp-tg
  ]
}

# Autoscaling Target
resource "aws_appautoscaling_target" "flaskapp" {
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.web-cluster.name}/${aws_ecs_service.flaskapp.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  min_capacity       = 1
  max_capacity       = 2
}

# Autoscaling Policy for both scaling out and scaling in
resource "aws_appautoscaling_policy" "auto_scaling" {
  name               = "Auto Scaling"
  service_namespace  = "ecs"
  resource_id        = aws_appautoscaling_target.flaskapp.resource_id
  scalable_dimension = aws_appautoscaling_target.flaskapp.scalable_dimension
  policy_type        = "TargetTrackingScaling"

  target_tracking_scaling_policy_configuration {
    target_value       = 70.0 
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    scale_out_cooldown  = 300
    scale_in_cooldown   = 300
  }
}