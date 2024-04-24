<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_composer"></a> [composer](#module\_composer) | ./modules/composer | n/a |
| <a name="module_etl-infra"></a> [etl-infra](#module\_etl-infra) | ./modules/etl-infra | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The full project name | `string` | `""` | no |
| <a name="input_service_account"></a> [service\_account](#input\_service\_account) | The email address for the service account to grant access to resources | `string` | `""` | no |
| <a name="input_user_email"></a> [user\_email](#input\_user\_email) | The email address for a user to grant access to resources | `string` | `""` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->