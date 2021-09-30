##############################################################################
# VPC
##############################################################################

output vpc_id {
  description = "ID of VPC created"
  value       = module.multizone_bastion_vpc.vpc_id
}

output acls {
  description = "ID of ACL created for subnets"
  value       = module.multizone_bastion_vpc.acls
}

output public_gateways {
  description = "Public gateways created"
  value       = module.multizone_bastion_vpc.public_gateways
}

##############################################################################

##############################################################################
# Subnet Outputs
##############################################################################

output subnet_ids {
  description = "The IDs of the subnets"
  value       = module.multizone_bastion_vpc.subnet_ids
}

output subnet_detail_list {
  description = "A list of subnets containing names, CIDR blocks, and zones."
  value       = module.multizone_bastion_vpc.subnet_detail_list
}

output subnet_zone_list {
  description = "A list containing subnet IDs and subnet zones"
  value       = module.multizone_bastion_vpc.subnet_zone_list
}

output subnet_tier_list {
  description = "An object containing tiers, each key containing a list of subnets in that tier"
  value       = module.multizone_bastion_vpc.subnet_tier_list
}

##############################################################################

##############################################################################
# Cluster Outputs
##############################################################################

output cluster_id {
  description = "ID of cluster created"
  value       = module.roks_cluster.id
}

output cluster_name {
  description = "Name of cluster created"
  value       = module.roks_cluster.name
}

output cluster_private_service_endpoint_url {
    description = "URL For Cluster Private Service Endpoint"
    value       = module.roks_cluster.private_service_endpoint_url
}

output cluster_private_service_endpoint_port {
    description = "Port for Cluster private service endpoint"
    value       = module.roks_cluster.private_service_endpoint_port
}

##############################################################################