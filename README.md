<!-- Update the title to match the module name and add a description -->
# Terraform IBM ICSE Key Management Module

This module allows users to create and manage keys, key rings, and key policies in a HPCS or Key Protect Instance. This module is designed to be used as part of a larger architecture.

---

<!-- UPDATE BADGE: Update the link for the badge below-->
[![Build Status](https://github.com/terraform-ibm-modules/terraform-ibm-module-template/actions/workflows/ci.yml/badge.svg)](https://github.com/terraform-ibm-modules/terraform-ibm-module-template/actions/workflows/ci.yml)
[![semantic-release](https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg)](https://github.com/semantic-release/semantic-release)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)

---

## Table of Contents

1. [Usage](#usage)
1. [Examples](#examples)
1. [Modules](#modules)
1. [Key Management Instance Types](#key-management-instance-types)
1. [Resources](#resources)
1. [Inputs](#inputs)
1. [Outputs](#outputs)
1. [Contributing](#contributing)

---

<!-- 1.  Create a PR to enable the upgrade test by removing the `t.Skip` line in `tests/pr_test.go`. -->

<!-- Remove the content in this previous H2 heading -->

## Usage

```terraform
module icse-key-management {
  source                    = "github.com/terraform-ibm-modules/terraform-ibm-icse-key-management-module"
  region                    = "us-south"
  prefix                    = "my-prefix"
  tags                      = ["icse", "cloud-services"]
  resource_group_id         = "<your resource group id>"
  service_endpoints         = "public"
  authorize_vpc_reader_role = var.authorize_vpc_reader_role
  keys                      = [
    {
      key_ring = "at-test-slz-ring"
      name     = "at-test-slz-key"
      root_key = true
    },
    {
      key_ring = "at-test-slz-ring"
      name     = "at-test-atracker-key"
      root_key = true
    },
    {
      key_ring = "at-test-slz-ring"
      name     = "at-test-vsi-volume-key"
      root_key = true
    },
  ]
}
```

---

## Examples

- [Default example](examples/basic)

---

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >=1.43.0 |

---

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_key_map"></a> [key\_map](#module\_key\_map) | ./config_modules/list_to_map | n/a |
| <a name="module_policies_map"></a> [policies\_map](#module\_policies\_map) | ./config_modules/list_to_map | n/a |

---

## Key Management Instance Types

This module supports these three patterns for a key management instance:
- Use an intialized Hyper Protect Crypto Services. (For more information about HPCS see the documentation [here](https://cloud.ibm.com/docs/hs-crypto?topic=hs-crypto-get-started).)
- Use an existing Key Protect Instance
- Create a New Key Protect instance

---

## Resources

| Name | Type |
|------|------|
| [ibm_iam_authorization_policy.block_storage_policy](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/iam_authorization_policy) | resource |
| [ibm_iam_authorization_policy.server_protect_policy](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/iam_authorization_policy) | resource |
| [ibm_kms_key.key](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/kms_key) | resource |
| [ibm_kms_key_policies.key_policy](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/kms_key_policies) | resource |
| [ibm_kms_key_rings.rings](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/kms_key_rings) | resource |
| [ibm_resource_instance.kms](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/resource_instance) | resource |
| [ibm_resource_instance.hpcs_instance](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/data-sources/resource_instance) | data source |
| [ibm_resource_instance.kms](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/data-sources/resource_instance) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_authorize_vpc_reader_role"></a> [authorize\_vpc\_reader\_role](#input\_authorize\_vpc\_reader\_role) | Create a service authorization to allow the key management service created by this module Reader role for IAM access to VPC block storage resources. This allows for block storage volumes for VPC to be encrypted using keys from the key management service | `bool` | `true` | no |
| <a name="input_keys"></a> [keys](#input\_keys) | List of keys to be created for the service | <pre>list(<br>    object({<br>      name            = string<br>      root_key        = optional(bool)<br>      payload         = optional(string)<br>      key_ring        = optional(string) # Any key_ring added will be created<br>      force_delete    = optional(bool)<br>      endpoint        = optional(string) # can be public or private<br>      iv_value        = optional(string) # (Optional, Forces new resource, String) Used with import tokens. The initialization vector (IV) that is generated when you encrypt a nonce. The IV value is required to decrypt the encrypted nonce value that you provide when you make a key import request to the service. To generate an IV, encrypt the nonce by running ibmcloud kp import-token encrypt-nonce. Only for imported root key.<br>      encrypted_nonce = optional(string) # The encrypted nonce value that verifies your request to import a key to Key Protect. This value must be encrypted by using the key that you want to import to the service. To retrieve a nonce, use the ibmcloud kp import-token get command. Then, encrypt the value by running ibmcloud kp import-token encrypt-nonce. Only for imported root key.<br>      policies = optional(<br>        object({<br>          rotation = optional(<br>            object({<br>              interval_month = number<br>            })<br>          )<br>          dual_auth_delete = optional(<br>            object({<br>              enabled = bool<br>            })<br>          )<br>        })<br>      )<br>    })<br>  )</pre> | <pre>[<br>  {<br>    "key_ring": "at-test-slz-ring",<br>    "name": "at-test-slz-key",<br>    "root_key": true<br>  },<br>  {<br>    "key_ring": "at-test-slz-ring",<br>    "name": "at-test-atracker-key",<br>    "root_key": true<br>  },<br>  {<br>    "key_ring": "at-test-slz-ring",<br>    "name": "at-test-vsi-volume-key",<br>    "root_key": true<br>  }<br>]</pre> | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the service to create or find from data. Created service instances will include the prefix. | `string` | `"kms"` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | The prefix that you would like to append to your resources | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The region to which to deploy the VPC | `string` | n/a | yes |
| <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id) | Resource group ID to use for provision of resources or to find existing resources. | `string` | `null` | no |
| <a name="input_service_endpoints"></a> [service\_endpoints](#input\_service\_endpoints) | Service endpoints. Can be `public`, `private`, or `public-and-private` | `string` | `"private"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | List of Tags for the resource created | `list(string)` | `null` | no |
| <a name="input_use_data"></a> [use\_data](#input\_use\_data) | Use existing Key Protect instance. | `bool` | `false` | no |
| <a name="input_use_hs_crypto"></a> [use\_hs\_crypto](#input\_use\_hs\_crypto) | Use HyperProtect Crypto Services. HPCS cannot be initialized in this module. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_key_management_crn"></a> [key\_management\_crn](#output\_key\_management\_crn) | CRN for KMS instance |
| <a name="output_key_management_guid"></a> [key\_management\_guid](#output\_key\_management\_guid) | GUID for KMS instance |
| <a name="output_key_management_name"></a> [key\_management\_name](#output\_key\_management\_name) | Name of key management service |
| <a name="output_key_rings"></a> [key\_rings](#output\_key\_rings) | Key rings created by module |
| <a name="output_keys"></a> [keys](#output\_keys) | List of names and ids for keys created. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

<!-- Leave this section as is so that your module has a link to local development environment set up steps for contributors to follow -->

## Contributing

You can report issues and request features for this module in the [terraform-ibm-issue-tracker](https://github.com/terraform-ibm-modules/terraform-ibm-issue-tracker/issues) repo. See [Report an issue or request a feature](https://github.com/terraform-ibm-modules/.github/blob/main/.github/SUPPORT.md).

To set up your local development environment, see [Local development setup](https://terraform-ibm-modules.github.io/documentation/#/local-dev-setup) in the project documentation.

<!-- BEGIN EXAMPLES HOOK -->
## Examples

- [ Default example](examples/basic)
<!-- END EXAMPLES HOOK -->
