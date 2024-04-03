module cc_creds {
    source ="../../modules/cc_creds_gcp"
    cc_cred_path = var.cc_cred_path
}

module serviceaccount {
  source ="../../modules/basic_serviceaccount"
  cc_cred = module.cc_creds.cred_obj
  serviceaccount_name = "${var.app_name}-${var.stagging_env}-SA"
  serviceaccount_description = "Application service account for ${var.app_name}-${var.stagging_env}"
}

module servicekey {
  source = "../../modules/basic_cluster_key"
  cc_cred = module.cc_creds.cred_obj
  serviceaccount_id =  module.serviceaccount.serviceaccount_id
  key_name = "Key_${var.app_name}-${var.stagging_env}"
  key_description = "cluster key for ${var.app_name}-${var.stagging_env}"
}

module GCPsecret {
  source = "../../modules/gcp_ssm"
  cc_cred_path = "CC-${var.app_name}-${var.stagging_env}"
  cc_cred_obj = {
    kafka_api_key = module.servicekey.cluster_key.id
    kafka_api_secret =  module.servicekey.cluster_key.secret
    kafka_rest_endpoint = module.cc_creds.cred_obj.kafka_rest_endpoint
    brokerurl = module.cc_creds.cred_obj.brokerurl
  }
}

module newtopic {
  source = "../../modules/basic_topic"
  cc_cred = module.cc_creds.cred_obj
  topic_name =  var.topic_names
  app_name =  var.app_name  
}

module "rbac-write" {
  source = "../../modules/basic_role"
  cc_cred = module.cc_creds.cred_obj
  topic_names =  module.newtopic.topic_names
  serviceaccount_id =  module.serviceaccount.serviceaccount_id
  role_name = "DeveloperWrite"
}
module "rbac-read" {
  source = "../../modules/basic_role"
  cc_cred = module.cc_creds.cred_obj
  topic_names =  ["*"]
  serviceaccount_id =  module.serviceaccount.serviceaccount_id
  role_name = "DeveloperRead"
}
module "rbac-cluster" {
  source = "../../modules/cluster_role"
  cc_cred = module.cc_creds.cred_obj
  serviceaccount_id =  module.serviceaccount.serviceaccount_id
  role_name = "CloudClusterAdmin"
}

output "topic_names" {
  value = module.newtopic.topic_names
}
output cred_path {
  value = module.GCPsecret.cred_path  
}
output cc_api_key {
  value = module.GCPsecret.cc_api_key
}

