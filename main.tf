provider "aws" {
	region = "ap-south-1"
}

resource "aws_ecs_cluster" "test-cluster" {
  name = "monil-cluster"
}




resource "aws_ecs_task_definition" "springboot-example2" {
  family                   = "springboot"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 512
  memory                   = 1024

  container_definitions = <<DEFINITION
[
  {
    "image": "702620960245.dkr.ecr.ap-south-1.amazonaws.com/monil2311-registry:latest",
    "cpu": 512,
    "memory": 1024,
    "name": "monil2311-springboot-example2",
    "networkMode": "awsvpc",
    "portMappings": [
      {
        "containerPort": 8080,
        "hostPort": 8080
      },
	  {
        "containerPort": 80,
        "hostPort": 80
      }
    ]
  }
]
DEFINITION
}

resource "aws_ecs_service" "test-service" {
  name            = "testapp-service"
  cluster         = aws_ecs_cluster.test-cluster.id
  task_definition = aws_ecs_task_definition.springboot-example2.arn
  desired_count   = var.app_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = [aws_security_group.web-sg-monil.id]
    subnets          = [aws_subnet.dev-public-1.id,aws_subnet.dev-public-2.id]
    assign_public_ip = true
  }

  depends_on = [aws_iam_role_policy_attachment.ecs_task_execution_role]
}