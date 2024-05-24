variable "cluster_name" {
  type     = string
  description = "Visible name of the cluster"
  nullable = false
}
variable "cluster_cloud" {
  type     = string
  description = "cloud provider: AWS | GCP | AZURE"
  nullable = false
}
variable "cluster_region" {
  type     = string
  description = "cloud provider specific region name"
  nullable = false
}
variable "cluster_cku" {
  type     = number
  description = "initial CKU count, minimum of 2 for multi-AZ"
  nullable = false
  default = 2
}
variable "cc_cred" {
  type     = object({
    cloud_api_key = string
    cloud_api_secret = string
    envid = string    
  })
  description = "Credential object from GCP"
  nullable = false
}


