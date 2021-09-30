##############################################################################
# Worker Pool
##############################################################################

locals {
    work_pool_map = {
        for pool in var.worker_pools:
        pool.name => pool
    }
}

resource ibm_container_vpc_worker_pool pool {
    for_each           = local.work_pool_map
    vpc_id             = var.vpc_id
    resource_group_id  = var.resource_group_id
    entitlement        = var.entitlement
    cluster            = var.cluster_name_id
    worker_pool_name   = each.value.name
    flavor             = each.value.machine_type
    worker_count       = each.value.workers_per_zone

    dynamic zones {
        for_each = var.subnets
        content {
            subnet_id = zones.value.id
            name      = zones.value.zone
        }
    }
}

##############################################################################