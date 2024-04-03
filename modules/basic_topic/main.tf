# https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/confluent_kafka_topic

resource "confluent_kafka_topic" "newtopic" {  
  count = length(var.topic_name)  
  topic_name = "${var.app_name}_${var.topic_name[count.index]}"  

  partitions_count = 6
  kafka_cluster {
    id = var.cc_cred.clusterid
  }
  lifecycle {
    prevent_destroy = false
  }
  config = {
    "retention.ms" = "604800000"
    "cleanup.policy" = "delete"

  }

  rest_endpoint = var.cc_cred.kafka_rest_endpoint
  credentials {
    key    = var.cc_cred.kafka_api_key
    secret = var.cc_cred.kafka_api_secret
  }

}

output "topic_names" {
  value = "${resource.confluent_kafka_topic.newtopic.*.topic_name}"
}

