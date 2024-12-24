resource "aws_ecs_cluster" "web-cluster" {
  name = "web-server"
}

resource "aws_ecs_cluster_capacity_providers" "web-server" {
  cluster_name = aws_ecs_cluster.web-cluster.name

  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}