
#https://registry.terraform.io/modules/GoogleCloudPlatform/secret-manager/google/latest
data "google_secret_manager_secret_version" "CC-Credential" {
  provider = google-beta
  secret   = var.cc_cred_path
}

locals {
  secret_variables = jsondecode(data.google_secret_manager_secret_version.CC-Credential.secret_data)
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

}

output "ssm" {   value = local.secret_variables }
output "kafka_api_key"        { value = local.secret_variables.kafka_api_key }
output "kafka_api_secret"     { value = local.secret_variables.kafka_api_secret }
output "kafka_rest_endpoint"  { value = local.secret_variables.kafka_rest_endpoint }
output "envid"                { value = local.secret_variables.envid }
output "clusterid"            { value = local.secret_variables.clusterid }
