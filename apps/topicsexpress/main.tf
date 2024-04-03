
module express_topics {
    source ="../../modules/topics_express"
    topic_names = ["failed_orders"] #,"user_accounts"
    app_name = "test2"
    stagging_env = "NP"
    cc_cred_path = "CHAPMAN-chapman_test2"        
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




