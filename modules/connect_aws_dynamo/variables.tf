variable "app_name" {
  type     = string
  description = "(topic prefix) Name of the application producing data to the topic"
  nullable = false
}
variable "topic_names" {
  type     = list
  description = "list of topic names"
  nullable = false
}
variable "hash_key" {
  type     = string
  description = "value for hashing dynamo tables"
  nullable = false
}
variable "serviceaccount_id" {
  type     = string
  description = "CC service account id"
  nullable = false
}

variable "aws_creds" {
    type     = object({
    aws_key = string
    aws_secret = string    
  })
  description = "AWS credentials for connector"
  nullable = false
}

variable "cc_cred" {
  type     = object({
    cloud_api_key = string
    cloud_api_secret = string
    clusterid = string
    envid = string    
  })
  description = "Credential object from secret manager"
  nullable = false
}


