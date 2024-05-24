#https://registry.terraform.io/modules/GoogleCloudPlatform/secret-manager/google/latest

variable "cc_cred_path" {
  type = string
  nullable = false
}

variable "cc_cred_obj" {
  type = object({
    kafka_api_key = string
    kafka_api_secret = string
    kafka_rest_endpoint = string
    brokerurl = string
    cloud_api_key = string
    cloud_api_secret =  string
    envid =  string
    clusterid = string
  })
  description = "Credential object being written to GCP secrets manager"
  nullable = false
}

resource "google_secret_manager_secret" "my-secret" {
  provider = google-beta
  secret_id = var.cc_cred_path 
  replication {
   auto { } 
  }
}

resource "google_secret_manager_secret_version" "my-secret-version" {
  provider = google-beta
  secret   = google_secret_manager_secret.my-secret.id
  secret_data =  jsonencode({
    "cloud_api_key" :"${var.cc_cred_obj.cloud_api_key}",
    "cloud_api_secret" :"${var.cc_cred_obj.cloud_api_secret}",
    "envid" :"${var.cc_cred_obj.envid}",
    "clusterid" :"${var.cc_cred_obj.clusterid}",
    "kafka_api_key"       :"${var.cc_cred_obj.kafka_api_key}",
    "kafka_api_secret"    :"${var.cc_cred_obj.kafka_api_secret}",
    "kafka_rest_endpoint" :"${var.cc_cred_obj.kafka_rest_endpoint}",
    "brokerurl" :"${var.cc_cred_obj.brokerurl}"
  })
}

output cred_path {
  value = var.cc_cred_path  
}

