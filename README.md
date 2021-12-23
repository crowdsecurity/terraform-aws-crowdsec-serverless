## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |
| <a name="provider_template"></a> [template](#provider\_template) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_authorizer"></a> [authorizer](#module\_authorizer) | terraform-aws-modules/lambda/aws | 2.17.0 |
| <a name="module_crowdsec-sg"></a> [crowdsec-sg](#module\_crowdsec-sg) | terraform-aws-modules/security-group/aws | 4.3.0 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_apigatewayv2_authorizer.gateway_authorizer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_authorizer) | resource |
| [aws_cloudwatch_log_group.crowdsec-lapi](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_db_subnet_group.dbsubnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group) | resource |
| [aws_ecs_cluster.crowdsec-lapi](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster) | resource |
| [aws_ecs_service.crowdsec-service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_task_definition.crowdsec-lapi](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_iam_role.ecs_task_execution_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.lapi-cloudwatch-policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_rds_cluster.csdb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster) | resource |
| [aws_service_discovery_private_dns_namespace.crowdsec](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/service_discovery_private_dns_namespace) | resource |
| [aws_service_discovery_service.crowdsec](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/service_discovery_service) | resource |
| [random_password.bouncer_key](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [random_password.csdbpassword](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [aws_availability_zones.az](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_iam_policy_document.ecs_task_execution_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [template_file.cs_acquis](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
| [template_file.cs_config](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_acquis"></a> [acquis](#input\_acquis) | Path to acquis file. | `string` | `""` | no |
| <a name="input_aws_apigateway_api_execution_arn"></a> [aws\_apigateway\_api\_execution\_arn](#input\_aws\_apigateway\_api\_execution\_arn) | Execution ARN of api gateway to deploy crowdsec powered authorizer | `string` | `""` | no |
| <a name="input_aws_apigateway_id"></a> [aws\_apigateway\_id](#input\_aws\_apigateway\_id) | ID of api gateway to deploy crowdsec powered authorizer | `string` | `""` | no |
| <a name="input_captcha_secret"></a> [captcha\_secret](#input\_captcha\_secret) | Recaptcha secret key | `string` | n/a | yes |
| <a name="input_cloudwatch_group_name"></a> [cloudwatch\_group\_name](#input\_cloudwatch\_group\_name) | Cloudwatch group to read logs | `string` | n/a | yes |
| <a name="input_collections"></a> [collections](#input\_collections) | Collections to install. | `list(string)` | `[]` | no |
| <a name="input_config"></a> [config](#input\_config) | Path to file containing custom Crowdsec configration | `string` | `""` | no |
| <a name="input_crowdsec_cpu"></a> [crowdsec\_cpu](#input\_crowdsec\_cpu) | Amount of vCPU units for CrowdSec task. | `number` | `256` | no |
| <a name="input_crowdsec_memory"></a> [crowdsec\_memory](#input\_crowdsec\_memory) | Amount of memory for CrowdSec task | `number` | `512` | no |
| <a name="input_parsers"></a> [parsers](#input\_parsers) | Parsers to install. | `list(string)` | `[]` | no |
| <a name="input_profiles"></a> [profiles](#input\_profiles) | Path to file containing custom Crowdsec profiles | `string` | `""` | no |
| <a name="input_scenarios"></a> [scenarios](#input\_scenarios) | List of scenarios to install | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_apigatewayv2_authorizer_id"></a> [aws\_apigatewayv2\_authorizer\_id](#output\_aws\_apigatewayv2\_authorizer\_id) | n/a |
