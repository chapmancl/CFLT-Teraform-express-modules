# https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/confluent_service_account

provider "confluent" {
  cloud_api_key       = var.cc_cred.cloud_api_key
  cloud_api_secret    = var.cc_cred.cloud_api_secret  
}

resource "confluent_service_account" "basic_sa" {
  display_name = var.serviceaccount_name
  description  = var.serviceaccount_description
}

output serviceaccount_id {
  value = resource.confluent_service_account.basic_sa.id
}
output serviceaccount_name {
  value = resource.confluent_service_account.basic_sa.display_name
}


