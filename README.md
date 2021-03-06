This terraform module allows users to protect AWS serverless stacks using CrowdSec. It deploys CrowdSec in a ECS fargate container. This CrowdSec instance reads logs from CloudWatch and infers malevolent IPs. It then creates a lambda authorizer and binds it to the provided API gateway. This authorizer then blocks/captcha IPs inferred by CrowdSec.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 3.63.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.1.0 |
| <a name="provider_template"></a> [template](#provider\_template) | 2.2.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_authorizer"></a> [authorizer](#module\_authorizer) | terraform-aws-modules/lambda/aws | 2.17.0 |
| <a name="module_crowdsec-sg"></a> [crowdsec-sg](#module\_crowdsec-sg) | terraform-aws-modules/security-group/aws | 4.3.0 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_api_gateway_authorizer.gateway_authorizer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_authorizer) | resource |
| [aws_apigatewayv2_authorizer.gateway_authorizer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_authorizer) | resource |
| [aws_cloudwatch_log_group.crowdsec-lapi](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_db_subnet_group.dbsubnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group) | resource |
| [aws_ecs_cluster.crowdsec-lapi](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster) | resource |
| [aws_ecs_service.crowdsec-service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_task_definition.crowdsec-lapi](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_iam_role.ecs_task_execution_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.lapi-cloudwatch-policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.lapi-exec-policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_rds_cluster.csdb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster) | resource |
| [aws_service_discovery_private_dns_namespace.crowdsec](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/service_discovery_private_dns_namespace) | resource |
| [aws_service_discovery_service.crowdsec](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/service_discovery_service) | resource |
| [random_password.bouncer_key](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_password.csdbpassword](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [aws_availability_zones.az](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_iam_policy_document.ecs_task_execution_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [template_file.cs_acquis](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
| [template_file.cs_config](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |

**Notes**
- Depending upon your input `create_vpc` this module may create a VPC and subnets
- RDS is created and used by CrowdSec to persist decisions, alerts, keys etc.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_acquis"></a> [acquis](#input\_acquis) | Path to acquis file. | `string` | `""` | no |
| <a name="input_aws_apigateway_api_execution_arn"></a> [aws\_apigateway\_api\_execution\_arn](#input\_aws\_apigateway\_api\_execution\_arn) | Execution ARN of api gateway to deploy crowdsec powered authorizer | `string` | `""` | no |
| <a name="input_aws_apigateway_id"></a> [aws\_apigateway\_id](#input\_aws\_apigateway\_id) | ID of api gateway to deploy crowdsec powered authorizer | `string` | `""` | no |
| <a name="input_aws_apigateway_v2_api_execution_arn"></a> [aws\_apigateway\_v2\_api\_execution\_arn](#input\_aws\_apigateway\_v2\_api\_execution\_arn) | Execution ARN of api gateway v2 to deploy crowdsec powered authorizer | `string` | `""` | no |
| <a name="input_aws_apigateway_v2_id"></a> [aws\_apigateway\_v2\_id](#input\_aws\_apigateway\_v2\_id) | ID of api gateway v2 to deploy crowdsec powered authorizer | `string` | `""` | no |
| <a name="input_captcha_secret"></a> [captcha\_secret](#input\_captcha\_secret) | Recaptcha secret key | `string` | n/a | yes |
| <a name="input_cloudwatch_group_name"></a> [cloudwatch\_group\_name](#input\_cloudwatch\_group\_name) | Cloudwatch group to read logs | `string` | n/a | yes |
| <a name="input_collections"></a> [collections](#input\_collections) | Collections to install. | `list(string)` | `[]` | no |
| <a name="input_config"></a> [config](#input\_config) | Path to file containing custom Crowdsec configration | `string` | `""` | no |
| <a name="input_create_vpc"></a> [create\_vpc](#input\_create\_vpc) | Whether to create a separate VPC to deploy CrowdSec infra in | `bool` | `true` | no |
| <a name="input_crowdsec_cpu"></a> [crowdsec\_cpu](#input\_crowdsec\_cpu) | Amount of vCPU units for CrowdSec task. | `number` | `256` | no |
| <a name="input_crowdsec_memory"></a> [crowdsec\_memory](#input\_crowdsec\_memory) | Amount of memory for CrowdSec task | `number` | `512` | no |
| <a name="input_enable_v1_authorizer"></a> [enable\_v1\_authorizer](#input\_enable\_v1\_authorizer) | Create authorizer for REST api gateway | `bool` | `false` | no |
| <a name="input_enable_v2_authorizer"></a> [enable\_v2\_authorizer](#input\_enable\_v2\_authorizer) | Create authorizer for HTTP api gateway | `bool` | `false` | no |
| <a name="input_parsers"></a> [parsers](#input\_parsers) | Parsers to install. | `list(string)` | `[]` | no |
| <a name="input_private_subnets"></a> [private\_subnets](#input\_private\_subnets) | Private subnets to deploy CrowdSec infra in. Atleast 2 subnets should be provided, each in distinct AZ. MUST HAVE internet access. Not required if create\_vpc=true | `list(string)` | `[]` | no |
| <a name="input_profiles"></a> [profiles](#input\_profiles) | Path to file containing custom Crowdsec profiles | `string` | `""` | no |
| <a name="input_scenarios"></a> [scenarios](#input\_scenarios) | List of scenarios to install | `list(string)` | `[]` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID of VPC to deploy CrowdSec related infra in. Not required if create\_vpc=true | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_apigatewayv1_authorizer_id"></a> [aws\_apigatewayv1\_authorizer\_id](#output\_aws\_apigatewayv1\_authorizer\_id) | n/a |
| <a name="output_aws_apigatewayv2_authorizer_id"></a> [aws\_apigatewayv2\_authorizer\_id](#output\_aws\_apigatewayv2\_authorizer\_id) | n/a |
