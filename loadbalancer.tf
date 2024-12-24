resource "aws_alb" "flaskapp-alb" {
  name            = "FlaskApp-ALB"
  security_groups = [aws_security_group.http.id]
  subnets         = [aws_subnet.public_a.id, aws_subnet.public_b.id]

  enable_deletion_protection = false
}

resource "aws_alb_listener" "http" {
  load_balancer_arn = aws_alb.flaskapp-alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.flaskapp-tg.arn
  }
}

resource "aws_lb_target_group" "flaskapp-tg" {
  name     = "FlaskApp-TG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.flaskapp_vpc.id
  target_type = "ip"  

  health_check {
    path                = "/"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

output "alb_dns_name" {
  description = "The DNS name of the Application Load Balancer"
  value       = aws_alb.flaskapp-alb.dns_name
}
