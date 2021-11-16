module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name   = "crowdsec-vpc"
  cidr   = "10.0.0.0/16"
  azs    = data.aws_availability_zones.az.names

  private_subnets            = [for i in range(length(data.aws_availability_zones.az.names)) : cidrsubnet("10.0.0.0/16", 8, i)]
  public_subnets             = [for i in range(length(data.aws_availability_zones.az.names), 2 * length(data.aws_availability_zones.az.names)) : cidrsubnet("10.0.0.0/16", 8, i)]
  database_subnet_group_name = "csdbsubnetgroup"
  enable_nat_gateway         = true
  enable_dns_hostnames       = true
  enable_dns_support         = true
}

resource "aws_db_subnet_group" "dbsubnet" {
  name       = "dbsubnetgroup"
  subnet_ids = module.vpc.private_subnets
}


module "crowdsec-sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.3.0"
  vpc_id  = module.vpc.vpc_id
  name    = "crowdsecsg"
  ingress_with_self = [
    {
      rule = "all-all"
    },
  ]
  egress_rules = ["all-all"]
}

resource "aws_service_discovery_private_dns_namespace" "crowdsec" {
  name        = "crowdsec.local"
  description = "crowdsec LAPI"
  vpc         = module.vpc.vpc_id
}

resource "aws_service_discovery_service" "crowdsec" {
  name = "crowdsec"
  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.crowdsec.id
    dns_records {
      ttl  = 10
      type = "A"
    }
    routing_policy = "MULTIVALUE"
  }
  health_check_custom_config {
    failure_threshold = 1
  }
}


data "aws_availability_zones" "az" {
  state = "available"
}