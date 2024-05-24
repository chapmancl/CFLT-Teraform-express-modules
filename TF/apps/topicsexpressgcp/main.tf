
module express_topics {
    source ="../../modules/gcp_topics_express"
    topic_names = ["failed_orders"] #,"user_accounts"
    app_name = "testgcp"
    stagging_env = "NP"
    cc_cred_path = ""  # path to the cluster level api key credential (created in clusteronly) in GCP secrets manager
    gcp_projectid = "" # Google project id where secrets are stored
}

output "topic_names" {
  value = module.express_topics.topic_names
}
output cred_path {
  value = module.express_topics.cred_path  
}
output cc_api_key {
  value = module.express_topics.cc_api_key
}




