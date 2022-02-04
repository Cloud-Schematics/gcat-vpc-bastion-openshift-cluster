ibmcloud_api_key=""
TF_VERSION="1.0"
prefix="gcat-multizone"
region="us-south"
resource_group=""
classic_access=false
subnet_tiers=[ 
    { 
        name = "vpc" 
        acl_name = "vpc-acl" 
        subnets = { 
            zone-1 = [ { 
                name = "subnet-a" 
                cidr = "10.10.10.0/24" 
                public_gateway = true 
            } ], 
            zone-2 = [ { 
                name = "subnet-b" 
                cidr = "10.20.10.0/24" 
                public_gateway = true 
            } ], 
            zone-3 = [ { 
                name = "subnet-c" 
                cidr = "10.30.10.0/24" 
                public_gateway = true 
            } ]
        } 
    }, 
    { 
        name = "bastion" 
        acl_name = "bastion-acl" 
        subnets = { 
            zone-1 = [ { 
                name = "subnet-a" 
                cidr = "10.40.10.0/24" 
                public_gateway = false 
            } 
        ] 
    } 
} ]
use_public_gateways={ 
    zone-1 = true 
    zone-2 = false 
    zone-3 = false 
}
network_acls=[ { 
        name = "vpc-acl" 
        network_connections = ["bastion"] 
        add_cluster_rules = true 
        rules = [ { 
            name = "allow-all-inbound" 
            action = "allow" 
            direction = "inbound" 
            destination = "0.0.0.0/0" 
            source = "0.0.0.0/0" 
        }, { 
            name = "allow-all-outbound" 
            action = "allow" 
            direction = "outbound" 
            destination = "0.0.0.0/0" 
            source = "0.0.0.0/0" 
        } ] 
    }, 
    { 
        name = "bastion-acl" 
        network_connections = ["vpc"] 
        rules = [ { 
            name = "deny-all-inbound" 
            action = "allow" 
            direction = "inbound" 
            destination = "0.0.0.0/0" 
            source = "0.0.0.0/0" 
        }, { 
            name = "allow-all-outbound" 
            action = "allow" 
            direction = "outbound" 
            destination = "0.0.0.0/0" 
            source = "0.0.0.0/0" 
        } ] 
    } ]
security_group_rules=[ ]
machine_type="bx2.4x16"
workers_per_zone=2
entitlement="cloud_pak"
kube_version="4.7.30_openshift"
wait_till="IngressReady"
tags=[]
worker_pools=[]
