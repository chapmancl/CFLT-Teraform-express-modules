# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version

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
  })
  description = "Credential object from AWS"
  nullable = false
}

resource "aws_secretsmanager_secret" "my-secret" {
  name = var.cc_cred_path
  description = "application key for topics in ${var.cc_cred_obj.kafka_rest_endpoint}"
}

resource "aws_secretsmanager_secret_version" "my-secret-version" {
  secret_id     = aws_secretsmanager_secret.my-secret.id
  secret_string = jsonencode({
    "kafka_api_key"       :"${var.cc_cred_obj.kafka_api_key}",
    "kafka_api_secret"    :"${var.cc_cred_obj.kafka_api_secret}",
    "kafka_rest_endpoint" :"${var.cc_cred_obj.kafka_rest_endpoint}",
    "brokerurl" :"${var.cc_cred_obj.brokerurl}"
  })  
}

output cred_path {
  value = var.cc_cred_path  
}
output cc_api_key {
  value = var.cc_cred_obj.kafka_api_key
}

