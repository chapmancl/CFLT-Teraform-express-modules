
module express_topics {
    source ="../../modules/aws_topics_express"
    topic_names = ["failed_orders"] #,"user_accounts"
    app_name = "testawsapp"
    stagging_env = "NP"    
    aws_region = "us-east-2" 
    cc_cred_path = "" # path to the cluster level key in secrets manager
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




