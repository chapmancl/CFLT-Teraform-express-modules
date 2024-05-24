variable "serviceaccount_id" {
  type     = string
  description = "The service account which the role is bound to"
  nullable = false
}
variable "key_name" {
  type     = string
  description = "Visible name of the key"
  nullable = false
}
variable "key_description" {
  type     = string
  description = "Description of the key"
  nullable = false
}
variable "cc_cred" {
  type     = object({
    cloud_api_key = string
    cloud_api_secret = string
    kafka_rest_endpoint = string
    brokerurl = string
    envid = string
    clusterid = string
  })
  description = "Credential object from GCP"
  nullable = false
}


