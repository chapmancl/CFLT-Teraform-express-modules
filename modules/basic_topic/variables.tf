variable "app_name" {
  type     = string
  description = "(topic prefix) Name of the application producing data to the topic"
  nullable = false
}
variable "topic_name" {
  type     = list
  description = "list of topic names (this is appended to the app_name value)"
  nullable = false
}
variable "cc_cred" {
  type     = object({
    kafka_api_key = string
    kafka_api_secret = string
    kafka_rest_endpoint = string
    clusterid = string
  })
  description = "Credential object from keystore"
  nullable = false
}


