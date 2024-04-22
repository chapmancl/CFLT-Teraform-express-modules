# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret

data "aws_secretsmanager_secret" "byname" {
  name = var.cc_cred_path
}

data "aws_secretsmanager_secret_version" "current" {
  secret_id = data.aws_secretsmanager_secret.byname.id
}

locals {
  secret_variables =  jsondecode(data.aws_secretsmanager_secret_version.current.secret_string)
}

output "cred_obj" {
  value = {
    cloud_api_key = local.secret_variables.cloud_api_key
    cloud_api_secret = local.secret_variables.cloud_api_secret
    kafka_api_key = local.secret_variables.kafka_api_key
    kafka_api_secret = local.secret_variables.kafka_api_secret
    kafka_rest_endpoint = local.secret_variables.kafka_rest_endpoint
    brokerurl = local.secret_variables.brokerurl
    envid = local.secret_variables.envid
    clusterid = local.secret_variables.clusterid    
  }
  sensitive = true
}

output "envid"  { value = local.secret_variables.envid }
