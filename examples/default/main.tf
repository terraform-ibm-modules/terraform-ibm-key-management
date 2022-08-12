##############################################################################
# Locals
##############################################################################

locals {
  use_hs_crypto       = var.use_hs_crypto == true
  key_management_type = local.use_hs_crypto == true ? "hs-crypto" : var.use_data == true ? "data" : "resource"
}

##############################################################################

##############################################################################
# Create KMS instance or get from data
##############################################################################

resource "ibm_resource_instance" "kms" {
  count             = local.key_management_type == "resource" ? 1 : 0
  name              = "${var.prefix}-${var.name}"
  service           = "kms"
  plan              = "tiered-pricing"
  location          = var.region
  resource_group_id = var.resource_group_id
  tags              = var.tags
}

data "ibm_resource_instance" "kms" {
  count             = local.key_management_type == "data" ? 1 : 0
  name              = var.name
  resource_group_id = var.resource_group_id
}

data "ibm_resource_instance" "hpcs_instance" {
  count             = local.key_management_type == "hs-crypto" ? 1 : 0
  name              = var.name
  resource_group_id = var.resource_group_id
  service           = "hs-crypto"
}

##############################################################################

##############################################################################
# Key Management Locals
##############################################################################

locals {
  # Set intances for reference
  key_management_instance = (
    local.key_management_type == "hs-crypto"
    ? data.ibm_resource_instance.hpcs_instance[0]
    : local.key_management_type == "data"
    ? data.ibm_resource_instance.kms[0]
    : ibm_resource_instance.kms[0]
  )
  # Get GUID
  key_management_guid = local.key_management_instance.guid
  # Get CRN
  key_management_crn = local.key_management_instance.crn
}

##############################################################################

##############################################################################
# Create Key Rings
##############################################################################

resource "ibm_kms_key_rings" "rings" {
  for_each = toset(
    distinct([
      for encryption_key in var.keys :
      encryption_key.key_ring if encryption_key.key_ring != null
    ])
  )
  instance_id = local.key_management_guid
  key_ring_id = each.key
}

##############################################################################

##############################################################################
# Keys Map
##############################################################################

module "key_map" {
  source = "./config_modules/list_to_map"
  list   = var.keys
}

##############################################################################

##############################################################################
# Create Keys
##############################################################################

resource "ibm_kms_key" "key" {
  for_each        = module.key_map.value
  instance_id     = local.key_management_guid
  key_name        = "${var.prefix}-${each.value.name}"
  standard_key    = each.value.root_key == null ? null : !each.value.root_key
  payload         = each.value.payload
  key_ring_id     = each.value.key_ring == null ? null : ibm_kms_key_rings.rings[each.value.key_ring].key_ring_id
  force_delete    = each.value.force_delete != false ? true : each.value.force_delete
  endpoint_type   = each.value.endpoint
  iv_value        = each.value.iv_value
  encrypted_nonce = each.value.encrypted_nonce
  depends_on = [
    ibm_iam_authorization_policy.server_protect_policy,
    ibm_iam_authorization_policy.block_storage_policy
  ]
}

##############################################################################

##############################################################################
# Policies Map
##############################################################################

module "policies_map" {
  source            = "./config_modules/list_to_map"
  list              = var.keys
  lookup_field      = "policies"
  value_is_not_null = true
}

##############################################################################

##############################################################################
# Create Key Policies
##############################################################################

resource "ibm_kms_key_policies" "key_policy" {
  for_each      = module.policies_map.value
  instance_id   = local.key_management_guid
  endpoint_type = each.value.endpoint
  key_id        = ibm_kms_key.key[each.key].key_id
  # Dynamically create rotation block
  dynamic "rotation" {
    for_each = (each.value.policies.rotation == null ? [] : [each.value])
    content {
      interval_month = each.value.policies.rotation.interval_month
    }
  }
  dynamic "dual_auth_delete" {
    for_each = (each.value.policies.dual_auth_delete == null ? [] : [each.value])
    content {
      enabled = each.value.policies.dual_auth_delete.enabled
    }
  }
}

##############################################################################
