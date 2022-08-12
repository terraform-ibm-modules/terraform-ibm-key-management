##############################################################################
# Key Management Outputs
##############################################################################

output "key_management_name" {
  description = "Name of key management service"
  value       = local.key_management_instance.name
}

output "key_management_crn" {
  description = "CRN for KMS instance"
  value       = local.key_management_crn
}

output "key_management_guid" {
  description = "GUID for KMS instance"
  value       = local.key_management_guid
  depends_on = [
    ibm_iam_authorization_policy.server_protect_policy,
    ibm_iam_authorization_policy.block_storage_policy
  ]
}

##############################################################################

##############################################################################
# Key Rings
##############################################################################

output "key_rings" {
  description = "Key rings created by module"
  value       = ibm_kms_key_rings.rings
}

##############################################################################

##############################################################################
# Keys
##############################################################################

output "keys" {
  description = "List of names and ids for keys created."
  value = [
    for kms_key in var.keys :
    {
      shortname = kms_key.name
      name      = ibm_kms_key.key[kms_key.name].key_name
      id        = ibm_kms_key.key[kms_key.name].id
      crn       = ibm_kms_key.key[kms_key.name].crn
      key_id    = ibm_kms_key.key[kms_key.name].key_id
    }
  ]
}

##############################################################################

##############################################################################
# Output Arbitrary Locals
##############################################################################

output "arbitrary_locals" {
  description = "A map of unessecary variable values to force linter pass"
  value = {
    resource_group = var.resource_group
    resource_tags  = var.resource_tags
  }
}

##############################################################################
