# https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/confluent_api_key

provider "confluent" {
  cloud_api_key       = var.cc_cred.cloud_api_key
  cloud_api_secret    = var.cc_cred.cloud_api_secret  
}

resource "confluent_api_key" "cluster-api-key" {
  display_name = var.key_name
  description  = var.key_description
  owner {
    id          = var.serviceaccount_id
    api_version = "iam/v2"
    kind        = "ServiceAccount"
  }

  managed_resource {
    id          = var.cc_cred.clusterid
    api_version = "cmk/v2"
    kind        = "Cluster"

    environment {
      id = var.cc_cred.envid
    }
  }

  lifecycle {
    prevent_destroy = false
  }
}

output cluster_cred_obj {
  value = {
      kafka_api_key = confluent_api_key.cluster-api-key.id
      kafka_api_secret = confluent_api_key.cluster-api-key.secret
      kafka_rest_endpoint = var.cc_cred.kafka_rest_endpoint
      brokerurl = var.cc_cred.brokerurl
      envid = var.cc_cred.envid
      clusterid = var.cc_cred.clusterid
    }
}

output cluster_key {
  value = confluent_api_key.cluster-api-key
}
