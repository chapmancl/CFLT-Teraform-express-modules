variable "serviceaccount_id" {
  type     = string
  description = "The service account which the role is bound to"
  nullable = false
}
variable "role_name" {
  type     = string
  description = "The role name being applied to the binding"
  nullable = false
}
variable "topic_names" {
  type     = list
  description = "list of topic ids for binding roles"
  nullable = false
}
variable "cc_cred" {
  type     = object({
    cloud_api_key = string
    cloud_api_secret = string
    envid = string
    clusterid = string
  })
  description = "Credential object from keystore"
  nullable = false
}


