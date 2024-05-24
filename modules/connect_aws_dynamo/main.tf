#https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/confluent_connector

provider "confluent" {
  cloud_api_key    = var.cc_cred.cloud_api_key
  cloud_api_secret = var.cc_cred.cloud_api_secret
}

resource "confluent_connector" "dynamosink" {
  environment {
    id = var.cc_cred.envid
  }
  kafka_cluster {
    id = var.cc_cred.clusterid
  }

  // Block for custom *sensitive* configuration properties that are labelled with "Type: password" under "Configuration Properties" section in the docs:
  // https://docs.confluent.io/cloud/current/connectors/cc-amazon-dynamo-db-sink.html#configuration-properties
  // use vault, env, or override to set this
  config_sensitive = {
    "aws.access.key.id"     = var.aws_creds.aws_key
    "aws.secret.access.key" = var.aws_creds.aws_secret
  }

  // Block for custom *nonsensitive* configuration properties that are *not* labelled with "Type: password" under "Configuration Properties" section in the docs:
  // https://docs.confluent.io/cloud/current/connectors/cc-amazon-dynamo-db-sink.html#configuration-properties
  config_nonsensitive = {
    "topics"                   = join(", ",var.topic_names)  
    "input.data.format"        = "JSON"
    "connector.class"          = "DynamoDbSink"
    "name"                     = "DynamoDbSink_${var.app_name}"
    "kafka.auth.mode"          = "SERVICE_ACCOUNT"
    "kafka.service.account.id" = "${var.serviceaccount_id}"
    "aws.dynamodb.pk.hash"     = "${var.hash_key}"
    "aws.dynamodb.pk.sort"     = ""
    "tasks.max"                = "1"    
  }

}

output "connector_id" {
  value = confluent_connector.dynamosink.id
}
