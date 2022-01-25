##############################################################################
# IBM Cloud Provider
##############################################################################

provider ibm {
  ibmcloud_api_key      = var.ibmcloud_api_key
  region                = var.region
  ibmcloud_timeout      = 60
}

##############################################################################


##############################################################################
# Resource Group where VPC will be created
##############################################################################

data ibm_resource_group resource_group {
  name = var.resource_group
}

##############################################################################

##############################################################################
# Create VPC
##############################################################################

module multizone_bastion_vpc {
  source               = "./vpc"
  prefix               = var.prefix
  region               = var.region
  resource_group_id    = data.ibm_resource_group.resource_group.id
  classic_access       = var.classic_access
  subnet_tiers         = var.subnet_tiers
  use_public_gateways  = var.use_public_gateways
  network_acls         = var.network_acls
  security_group_rules = var.security_group_rules
}

##############################################################################


##############################################################################
# COS Instance
##############################################################################

resource ibm_resource_instance cos {
  name              = "${var.prefix}-cos"
  service           = "cloud-object-storage"
  plan              = "standard"
  location          = "global"
  resource_group_id = data.ibm_resource_group.resource_group.id

  parameters = {
    service-endpoints = "private"
  }

  timeouts {
    create = "1h"
    update = "1h"
    delete = "1h"
  }

}

##############################################################################


##############################################################################
# Create ROKS Cluster
##############################################################################

data ibm_container_cluster_versions cluster_versions {
  region = var.region
}

locals {
  latest = "${data.ibm_container_cluster_versions.cluster_versions.valid_openshift_versions[length(data.ibm_container_cluster_versions.cluster_versions.valid_openshift_versions) - 1]}_openshift"
}

module roks_cluster {
  source            = "./cluster"
  # Account Variables
  prefix            = var.prefix
  region            = var.region
  resource_group_id = data.ibm_resource_group.resource_group.id
  # VPC Variables
  vpc_id            = module.multizone_bastion_vpc.vpc_id
  subnets           = module.multizone_bastion_vpc.subnet_tier_list["vpc"]
  # Cluster Variables
  machine_type      = var.machine_type
  workers_per_zone  = var.workers_per_zone
  entitlement       = var.entitlement
  kube_version      = local.latest
  tags              = var.tags
  worker_pools      = var.worker_pools
  cos_id            = ibm_resource_instance.cos.id
}

##############################################################################