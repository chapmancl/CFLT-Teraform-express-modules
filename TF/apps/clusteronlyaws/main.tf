# https://github.com/confluentinc/terraform-provider-confluent/blob/master/examples/configurations/standard-kafka-rbac/main.tf
# https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/confluent_kafka_cluster

locals {
  key_prefix = "ConfluentAWSdemo"
  stagging_env = "NP"
  
  cluster_name = "test"
  cluster_cloud = "AWS"
  cluster_region = "us-east-2"
  
  cc_cred_global_path = "" # path to the cloud apikey in secrets manager
}

provider "aws" {  
  region  = local.cluster_region
}
module cccredsglobal {
    source ="../../modules/cc_creds_cloudapi_aws"
    cc_cred_path = local.cc_cred_global_path
}

module exampleCluster {
  source = "../../modules/basic_cluster"
  cc_cred = module.cccredsglobal.cred_obj
  cluster_name = "${local.key_prefix}_${local.cluster_name}"
  cluster_cloud = local.cluster_cloud
  cluster_region = local.cluster_region
}

module serviceaccount {
  source ="../../modules/basic_serviceaccount"
  cc_cred = module.cccredsglobal.cred_obj

  # modify below here  
  serviceaccount_name = "${local.key_prefix}-${local.cluster_name}-${local.stagging_env}"
  serviceaccount_description = "service account for ${local.key_prefix} automation demo"
}

module servicekey {
  source = "../../modules/basic_cluster_key"
  cc_cred = module.exampleCluster.cred_obj
  serviceaccount_id =  module.serviceaccount.serviceaccount_id
  
  # modify below here  
  key_name = "Key-${module.serviceaccount.serviceaccount_name}"
  key_description = "cluster key for ${module.serviceaccount.serviceaccount_name}"
}

module AWSsecret {
  # write the new key to secrete manager for managing the cluster via automation
  source = "../../modules/aws_ssm_clusterkey"
  cc_cred_path = "${local.key_prefix}_${local.cluster_name}-CLUSTERKEY"
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

module "rbac-cluster" {
  source = "../../modules/cluster_role"
  cc_cred = module.exampleCluster.cred_obj
  serviceaccount_id =  module.serviceaccount.serviceaccount_id
  
  # modify below here
  role_name = "CloudClusterAdmin"
}

output cluster_cred_path {
  value = module.AWSsecret.cred_path  
}
output cc_api_key {
  value = module.servicekey.cluster_key.id
}
output cluster_id {
  value = module.exampleCluster.cluster_id
}
output cluster_bootstrap_endpoint {
  value = module.exampleCluster.cluster_bootstrap_endpoint
}
output cluster_rest_endpoint {
  value = module.exampleCluster.cluster_rest_endpoint
}