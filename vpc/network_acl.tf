##############################################################################
# Network ACL
##############################################################################

locals {                 

      # List of network connections by ACL name
      network_connections = {
            for network_acl in var.network_acls:
            network_acl.name => network_acl.network_connections if network_acl.network_connections != null
      }

      # Create Connections Map where each tier contains a list of other tiers each tier will connect to
      connection_map = {
            for tier in var.subnet_tiers:
            tier.acl_name => local.network_connections[tier.acl_name]
      }

      # Create a list of inbound and outbound rules by tier
      tier_subnet_rules = {
            for tier in var.subnet_tiers:
            tier.name => flatten([
                  # For each subnet in a list of all subnets in that tier
                  for subnet in flatten([ for zone in keys(tier.subnets): tier.subnets[zone] ]):
                  [
                        { 
                              name        = "allow-inbound-${var.prefix}-${tier.name}-${subnet.name}"
                              action      = "allow"
                              direction   = "inbound"
                              destination = "0.0.0.0/0"
                              source      = subnet.cidr
                              tcp         = null
                              udp         = null
                              icmp        = null
                        },
                        {
                              name        = "allow-outbound-${var.prefix}-${tier.name}-${subnet.name}"
                              action      = "allow"
                              direction   = "outbound"
                              destination = subnet.cidr
                              source      = "0.0.0.0/0"
                              tcp         = null
                              udp         = null
                              icmp        = null
                        }
                  ]
            ])
      }

      cluster_rules = [
        # Cluster Rules
        {
            name        = "roks-create-worker-nodes-inbound"
            action      = "allow"
            source      = "161.26.0.0/16"
            destination = "0.0.0.0/0"
            direction   = "inbound"
            tcp         = null
            udp         = null
            icmp        = null
        },
        {
            name        = "roks-create-worker-nodes-outbound"
            action      = "allow"
            destination = "161.26.0.0/16"
            source      = "0.0.0.0/0"
            direction   = "outbound"
            tcp         = null
            udp         = null
            icmp        = null
        },
        {
            name        = "roks-nodes-to-service-inbound"
            action      = "allow"
            source      = "166.8.0.0/14"
            destination = "0.0.0.0/0"
            direction   = "inbound"
            tcp         = null
            udp         = null
            icmp        = null
        },
        {
            name        = "roks-nodes-to-service-outbound"
            action      = "allow"
            destination = "166.8.0.0/14"
            source      = "0.0.0.0/0"
            direction   = "outbound"
            tcp         = null
            udp         = null
            icmp        = null
        },
        # App Rules
        {
            name        = "allow-app-incoming-traffic-requests"
            action      = "allow"
            source      = "0.0.0.0/0"
            destination = "0.0.0.0/0"
            direction   = "inbound"
            tcp         = {
                port_min        = 1
                port_max        = 65535
                source_port_min = 30000
                source_port_max = 32767
            }
            udp         = null
            icmp        = null
        },
        {
            name        = "allow-app-outgoing-traffic-requests"
            action      = "allow"
            source      = "0.0.0.0/0"
            destination = "0.0.0.0/0"
            direction   = "outbound"
            tcp         = {
                source_port_min = 1
                source_port_max = 65535
                port_min        = 30000
                port_max        = 32767
            }
            udp         = null
            icmp        = null
        },
        {
            name        = "allow-lb-incoming-traffic-requests"
            action      = "allow"
            source      = "0.0.0.0/0"
            destination = "0.0.0.0/0"
            direction   = "inbound"
            tcp         = {
                source_port_min = 1
                source_port_max = 65535
                port_min        = 443
                port_max        = 443
            }
            udp         = null
            icmp        = null
        },
        {
            name        = "allow-lb-outgoing-traffic-requests"
            action      = "allow"
            source      = "0.0.0.0/0"
            destination = "0.0.0.0/0"
            direction   = "outbound"
            tcp         = {
                port_min        = 1
                port_max        = 65535
                source_port_min = 443
                source_port_max = 443
            }
            udp         = null
            icmp        = null
        }
      ]
      
      # ACL Objects                                                                                    
      acl_object = {
            for network_acl in var.network_acls:
            network_acl.name => {
                  rules             = flatten([
                        [
                              # These rules cannot be added in a conditional operator due to inconsistant typing
                              # This will add all cluster rules if the acl object contains add_cluster rules
                              for rule in local.cluster_rules:
                              rule if network_acl.add_cluster_rules == true
                        ],
                        [
                              # For each tier connected to the subnet, look up the connections needed
                              # for each ACL.
                              for connection in local.connection_map[network_acl.name]:
                              local.tier_subnet_rules[connection]
                        ],
                        network_acl.rules
                  ])
            }
      }
}

resource ibm_is_network_acl multitier_acl {
      for_each       = local.acl_object
      name           = "${var.prefix}-${each.key}"
      vpc            = ibm_is_vpc.vpc.id
      resource_group = var.resource_group_id

      # Create ACL rules
      dynamic rules {
            for_each = each.value.rules
            content {
                  name        = rules.value.name
                  action      = rules.value.action
                  source      = rules.value.source
                  destination = rules.value.destination
                  direction   = rules.value.direction

                  dynamic tcp {
                        for_each = rules.value.tcp == null ? [] : [rules.value]
                        content {
                              port_min        = rules.value.tcp.port_min
                              port_max        = rules.value.tcp.port_max
                              source_port_min = rules.value.tcp.source_port_min
                              source_port_max = rules.value.tcp.source_port_min
                        }
                  } 

                  dynamic udp {
                        for_each = rules.value.udp == null ? [] : [rules.value]
                        content {
                              port_min        = rules.value.udp.port_min
                              port_max        = rules.value.udp.port_max
                              source_port_min = rules.value.udp.source_port_min
                              source_port_max = rules.value.udp.source_port_min
                        }
                  } 

                  dynamic icmp {
                        for_each = rules.value.icmp == null ? [] : [rules.value]
                        content {
                              type = rules.value.icmp.type
                              code = rules.value.icmp.code
                        }
                  } 
            }
      }
}

##############################################################################