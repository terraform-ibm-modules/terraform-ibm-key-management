##############################################################################
# Account Variables
##############################################################################

variable "ibmcloud_api_key" {
  description = "The IBM Cloud platform API key needed to deploy IAM enabled resources."
  type        = string
  sensitive   = true
}

variable "region" {
  description = "The region to which to deploy the VPC"
  type        = string
}

variable "prefix" {
  description = "The prefix that you would like to append to your resources"
  type        = string
}

variable "tags" {
  description = "List of Tags for the resource created"
  type        = list(string)
  default     = null
}

variable "resource_group_id" {
  description = "Resource group ID to use for provision of resources or to find existing resources."
  type        = string
  default     = null
}

variable "service_endpoints" {
  description = "Service endpoints. Can be `public`, `private`, or `public-and-private`"
  type        = string
  default     = "private"

  validation {
    error_message = "Service endpoints can only be `public`, `private`, or `public-and-private`."
    condition     = contains(["public", "private", "public-and-private"], var.service_endpoints)
  }
}

variable "use_hs_crypto" {
  description = "Use HyperProtect Crypto Services. HPCS cannot be initialized in this module."
  type        = bool
  default     = false
}

variable "use_data" {
  description = "Use existing Key Protect instance."
  type        = bool
  default     = false
}

variable "authorize_vpc_reader_role" {
  description = "Create a service authorization to allow the key management service created by this module Reader role for IAM access to VPC block storage resources. This allows for block storage volumes for VPC to be encrypted using keys from the key management service"
  type        = bool
  default     = true
}

##############################################################################

##############################################################################
# Key Management Variables
##############################################################################

variable "name" {
  description = "Name of the service to create or find from data. Created service instances will include the prefix."
  type        = string
  default     = "kms"
}

variable "keys" {
  description = "List of keys to be created for the service"
  type = list(
    object({
      name            = string
      root_key        = optional(bool)
      payload         = optional(string)
      key_ring        = optional(string) # Any key_ring added will be created
      force_delete    = optional(bool)
      endpoint        = optional(string) # can be public or private
      iv_value        = optional(string) # (Optional, Forces new resource, String) Used with import tokens. The initialization vector (IV) that is generated when you encrypt a nonce. The IV value is required to decrypt the encrypted nonce value that you provide when you make a key import request to the service. To generate an IV, encrypt the nonce by running ibmcloud kp import-token encrypt-nonce. Only for imported root key.
      encrypted_nonce = optional(string) # The encrypted nonce value that verifies your request to import a key to Key Protect. This value must be encrypted by using the key that you want to import to the service. To retrieve a nonce, use the ibmcloud kp import-token get command. Then, encrypt the value by running ibmcloud kp import-token encrypt-nonce. Only for imported root key.
      policies = optional(
        object({
          rotation = optional(
            object({
              interval_month = number
            })
          )
          dual_auth_delete = optional(
            object({
              enabled = bool
            })
          )
        })
      )
    })
  )

  default = [
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

  validation {
    error_message = "Each key must have a unique name."
    condition     = length(var.keys) == 0 ? true : length(distinct(var.keys.*.name)) == length(var.keys.*.name)
  }

  validation {
    error_message = "Key endpoints can only be `public` or `private`."
    condition = length(var.keys) == 0 ? true : length([
      for kms_key in var.keys :
      true if kms_key.endpoint != null && kms_key.endpoint != "public" && kms_key.endpoint != "private"
    ]) == 0
  }

  validation {
    error_message = "Rotation interval month can only be from 1 to 12."
    condition = length(var.keys) == 0 ? true : length([
      for kms_key in [
        for rotation_key in [
          for policy_key in var.keys :
          policy_key if policy_key.policies != null
        ] :
        rotation_key if rotation_key.policies.rotation != null
      ] : true if kms_key.policies.rotation.interval_month < 1 || kms_key.policies.rotation.interval_month > 12
    ]) == 0
  }
}

##############################################################################

##############################################################################
# forced variables
##############################################################################

variable "resource_group" {
  description = "Mandatory value unused by this module"
  type        = string
  default     = null
}

variable "resource_tags" {
  description = "Mandatory value unused by this module"
  type        = list(string)
  default     = null
}

##############################################################################
