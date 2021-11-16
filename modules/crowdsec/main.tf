terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }
}

resource "aws_rds_cluster" "csdb" {
  cluster_identifier     = "csdb"
  engine                 = "aurora-postgresql"
  availability_zones     = data.aws_availability_zones.az.names
  database_name          = "crowdsec"
  master_username        = "crowdsec"
  master_password        = random_string.csdbpassword.result
  engine_mode            = "serverless"
  vpc_security_group_ids = [module.crowdsec-sg.security_group_id]
  db_subnet_group_name   = aws_db_subnet_group.dbsubnet.name
  skip_final_snapshot    = true
  apply_immediately      = true
  scaling_configuration {
    min_capacity = 2
    max_capacity = 2
  }
}

resource "random_string" "csdbpassword" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "random_string" "bouncer_key" {
  length           = 16
  special          = true
  override_special = "_%@"
}


resource "aws_ecs_cluster" "crowdsec-lapi" {
  name = "crowdsec-lapi"
}

resource "aws_ecs_service" "crowdsec-service" {
  name            = "lapi-crowdsec-service"
  cluster         = aws_ecs_cluster.crowdsec-lapi.id
  task_definition = aws_ecs_task_definition.crowdsec-lapi.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    security_groups = [module.crowdsec-sg.security_group_id]
    subnets         = module.vpc.private_subnets
  }
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200

  service_registries {
    registry_arn = aws_service_discovery_service.crowdsec.arn
  }
}


resource "aws_ecs_task_definition" "crowdsec-lapi" {
  family                   = "crowdsec-lapi"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  container_definitions = jsonencode([
    {
      name      = "lapi"
      image     = "public.ecr.aws/y9y5c8o6/crowdsec:latest@sha256:4b9c3489791122337d59efeca123852b519ad474cf8cd2d94e306873f62abdf3"
      cpu       = 10
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
        }
      ]
      entryPoint : ["/bin/sh", "-c"],
      command : [<<EOF
      echo '${data.template_file.cs_acquis.rendered}' > /etc/crowdsec/acquis.yaml  &&
      echo '${data.template_file.cs_config.rendered}' > /etc/crowdsec/config.yaml &&
      echo '${file(local.profiles)}' > /etc/crowdsec/profiles.yaml &&
      cscli bouncers add lambdaAuthorizer -k ${random_string.bouncer_key.result}&& 
      ./docker_start.sh
      EOF
      ],
      environment = [
        {
          name  = "COLLECTIONS"
          value = join(" ", var.collections)
        },
        {
          name  = "SCENARIOS"
          value = join(" ", var.scenarios)
        },
        {
          name  = "PARSERS"
          value = join(" ", var.parsers)
        },
        {
          name  = "AGENT_USERNAME"
          value = "a"
        },
        {
          name  = "AGENT_PASSWORD"
          value = "a"
        }
      ],
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "crowdsec-lapi/logs",
          awslogs-region        = data.aws_region.current.name,
          awslogs-stream-prefix = "crowdsec-lapi"
        }
      }
    }
  ])
}

resource "aws_cloudwatch_log_group" "crowdsec-lapi" {
  name              = "crowdsec-lapi/logs"
  retention_in_days = 7
}

resource "aws_instance" "console" {
  ami                    = "ami-0912f71e06545ad88"
  instance_type          = "t3.micro"
  vpc_security_group_ids = [module.crowdsec-sg.security_group_id]
  subnet_id              = module.vpc.public_subnets[0]
  key_name               = "sbscrowdsecindia"
}

data "aws_region" "current" {}

data "template_file" "cs_config" {
  template = file("${local.config}")
  vars = {
    db_type     = "postgresql"
    db_user     = "crowdsec"
    db_password = random_string.csdbpassword.result
    db_name     = "crowdsec"
    db_host     = aws_rds_cluster.csdb.endpoint
    db_port     = aws_rds_cluster.csdb.port
  }
}

data "template_file" "cs_acquis" {
  template = file("${local.acquis}")
  vars = {
    cloudwatch_group = var.cloudwatch_group_name
    stream_regexp    = ".*"
    aws_region       = data.aws_region.current.name
  }
}
