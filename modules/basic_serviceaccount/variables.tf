variable "serviceaccount_name" {
  type     = string
  description = "The name fo the service account"
  nullable = false
}
variable "serviceaccount_description" {
  type     = string
  description = "description for the service account"
  nullable = false
}
variable "cc_cred" {
  type     = object({
    cloud_api_key = string
    cloud_api_secret = string
    envid = string    
  })
  description = "Credential object from keystore"
  nullable = false
}

