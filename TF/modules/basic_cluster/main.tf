# shttps://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/confluent_kafka_cluster

provider "confluent" {
  cloud_api_key       = var.cc_cred.cloud_api_key
  cloud_api_secret    = var.cc_cred.cloud_api_secret  
}

resource "confluent_kafka_cluster" "new_cluster" {
  display_name = var.cluster_name
  availability = "MULTI_ZONE"
  cloud        = var.cluster_cloud
  region       = var.cluster_region
  #dedicated {
  #  cku = var.cluster_cku
  #}
  standard {}
  #basic {}
  

  environment {
    id = var.cc_cred.envid
  }

  lifecycle {
    prevent_destroy = false
  }
}

output cred_obj {
  value = {
    cloud_api_key = var.cc_cred.cloud_api_key
    cloud_api_secret = var.cc_cred.cloud_api_secret 
    kafka_rest_endpoint = confluent_kafka_cluster.new_cluster.rest_endpoint
    brokerurl = confluent_kafka_cluster.new_cluster.bootstrap_endpoint
    envid = var.cc_cred.envid
    clusterid = confluent_kafka_cluster.new_cluster.id
  }
  sensitive = true
}

output cluster_id {
  value = confluent_kafka_cluster.new_cluster.id
}
output cluster_bootstrap_endpoint {
  value = confluent_kafka_cluster.new_cluster.bootstrap_endpoint
}
output cluster_rest_endpoint {
  value = confluent_kafka_cluster.new_cluster.rest_endpoint
}
output cluster_rbac_crn {
  value = confluent_kafka_cluster.new_cluster.rbac_crn
}
