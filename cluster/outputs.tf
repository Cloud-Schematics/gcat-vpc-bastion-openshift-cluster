##############################################################################
# Cluster Outputs
##############################################################################

output id {
    description = "ID of cluster created"
    value       = ibm_container_vpc_cluster.cluster.id
    # Ensure cluster is finished before outputting variable from module
    depends_on  = [ ibm_container_vpc_cluster.cluster ]
}

output name {
    description = "Name of cluster created"
    value       = ibm_container_vpc_cluster.cluster.name
    # Ensure cluster is finished before outputting variable from module
    depends_on  = [ ibm_container_vpc_cluster.cluster ]
}

output private_service_endpoint_url {
    description = "URL For Cluster Private Service Endpoint"
    value       = ibm_container_vpc_cluster.cluster.private_service_endpoint_url
}

output private_service_endpoint_port {
    description = "Port for Cluster private service endpoint"
    value       = split(":", ibm_container_vpc_cluster.cluster.private_service_endpoint_url)[2]
}

##############################################################################
