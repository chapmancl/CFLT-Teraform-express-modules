# https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/confluent_role_binding

provider "confluent" {
  cloud_api_key       = var.cc_cred.cloud_api_key
  cloud_api_secret    = var.cc_cred.cloud_api_secret  
}

data "confluent_kafka_cluster" "cluster_lookup_id" {
  id = var.cc_cred.clusterid
  environment {
    id = var.cc_cred.envid
  }
}

resource "confluent_role_binding" "topic-rb" {  
  principal   = "User:${var.serviceaccount_id}"
  role_name   = var.role_name
  crn_pattern = "${data.confluent_kafka_cluster.cluster_lookup_id.rbac_crn}"  
}