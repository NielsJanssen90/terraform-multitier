resource "aws_ecs_task_definition" "FlaskApp" {
  family = "FlaskApp"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "1024"
  memory                   = "2048"
  task_role_arn           = var.labrole
  execution_role_arn      = var.labrole

  container_definitions = jsonencode([
    {
      name      = "FlaskApp"
      image     = "${aws_ecr_repository.flaskapp_repo.repository_url}:latest"
      entrypoint = ["/app/entrypoint.sh"]
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        }
      ]
      environment = [
        { name = "DB_USERNAME", value = var.db_username },
        { name = "DB_PASSWORD", value = random_password.flaskapp_db_password.result },
        { name = "DB_HOST", value = aws_db_instance.flaskapp.endpoint },
        { name = "DB_NAME", value = "flaskappdb" }
      ]
       logConfiguration = {
         logDriver = "awslogs"
         options = {
         awslogs-group         = "/ecs/FlaskApp"
         awslogs-region        = "us-east-1"
         awslogs-stream-prefix = "FlaskApp"
         }
       }
    }
  ])
}
resource "aws_cloudwatch_log_group" "ecs_log_group" {
  name              = "/ecs/FlaskApp"
  retention_in_days = 7
}

