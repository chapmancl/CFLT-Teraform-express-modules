# https://github.com/confluentinc/terraform-provider-confluent/blob/master/examples/configurations/standard-kafka-rbac/main.tf

locals {
  key_prefix = "#############"
  topic_names = ["topic_stocktrades","failed_orders"]
  app_name = "project_example"
  stagging_env = "NP"
  cc_cred_global_path = "${local.key_prefix}-GLOBAL" 
  serviceaccount_name = "${local.key_prefix}-example-${local.stagging_env}"
  serviceaccount_description = "service account for ${local.key_prefix} automation demo"
  
  cluster_name = "${local.key_prefix}_test"
  cluster_cloud = "GCP"
  cluster_region = "us-east1"

}
module cccredsglobal {
    source ="../../modules/cc_creds_global_gcp"
    cc_cred_path = local.cc_cred_global_path
}

module exampleCluster {
  source = "../../modules/basic_cluster"
  cc_cred = module.cccredsglobal.cred_obj
  cluster_name = local.cluster_name
  cluster_cloud = local.cluster_cloud
  cluster_region = local.cluster_region
}

module serviceaccount {
  source ="../../modules/basic_serviceaccount"
  cc_cred = module.cccredsglobal.cred_obj
  serviceaccount_name = local.serviceaccount_name
  serviceaccount_description = local.serviceaccount_description
}

module servicekey {
  source = "../../modules/basic_cluster_key"
  cc_cred = module.exampleCluster.cred_obj
  serviceaccount_id =  module.serviceaccount.serviceaccount_id
  
  # modify below here  
  key_name = "Key_${local.serviceaccount_name}"
  key_description = "cluster key for ${local.serviceaccount_name}"
}

module GCPappsecret {
  # write the new key to secrete manager for consumer/producer applications
  source = "../../modules/gcp_ssm_appkey"
  cc_cred_path = "${local.key_prefix}-${local.app_name}-${local.stagging_env}"
  cc_cred_obj = {
    kafka_api_key = module.servicekey.cluster_key.id
    kafka_api_secret =  module.servicekey.cluster_key.secret
    kafka_rest_endpoint = module.exampleCluster.cred_obj.kafka_rest_endpoint
    brokerurl = module.exampleCluster.cred_obj.brokerurl
  }
}
module GCPmanagesecret {
  # write the new key to secrete manager for managing the cluster via automation
  source = "../../modules/gcp_ssm_clusterkey"
  cc_cred_path = "${local.key_prefix}-${local.cluster_name}"
  cc_cred_obj = {
    cloud_api_key = module.cccredsglobal.cred_obj.cloud_api_key
    cloud_api_secret =  module.cccredsglobal.cred_obj.cloud_api_secret
    kafka_api_key = module.servicekey.cluster_key.id
    kafka_api_secret =  module.servicekey.cluster_key.secret
    kafka_rest_endpoint = module.exampleCluster.cluster_rest_endpoint
    brokerurl = module.exampleCluster.cluster_bootstrap_endpoint
    envid =  module.cccredsglobal.envid
    clusterid = module.exampleCluster.cluster_id
  }
}

module newtopic {
  source = "../../modules/basic_topic"
  # need the cluster key we just created
  cc_cred = module.servicekey.cluster_cred_obj
  
  # modify below here
  topic_name =  local.topic_names
  app_name =  local.app_name  
}

module "rbac-write" {
  source = "../../modules/basic_role"
  cc_cred = module.exampleCluster.cred_obj
  topic_names =  module.newtopic.topic_names
  serviceaccount_id =  module.serviceaccount.serviceaccount_id
  
  # modify below here
  role_name = "DeveloperWrite"
}
module "rbac-reed-all" {
  source = "../../modules/basic_role"
  cc_cred = module.exampleCluster.cred_obj
  topic_names =  ["*"]
  serviceaccount_id =  module.serviceaccount.serviceaccount_id
  
  # modify below here
  role_name = "DeveloperRead"
}
module "rbac-cluster" {
  source = "../../modules/cluster_role"
  cc_cred = module.exampleCluster.cred_obj
  serviceaccount_id =  module.serviceaccount.serviceaccount_id
  
  # modify below here
  role_name = "CloudClusterAdmin"
}

output "topic_names" {
  value = module.newtopic.topic_names
}
output cred_path {
  value = module.GCPappsecret.cred_path  
}
output cc_api_key {
  value = module.servicekey.cluster_key.id
}

