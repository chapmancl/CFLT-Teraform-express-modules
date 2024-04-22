variable "app_name" {
  type     = string
  description = "(topic prefix) Name of the application producing data to the topic"
  nullable = false
}
variable "topic_names" {
  type     = list
  description = "list of topic names (this is appended to the app_name value)"
  nullable = false
}
variable "stagging_env" {
  type     = string
  description = "environment lable (PROD | NP)"
  nullable = false
}
variable "cc_cred_path" {
  type = string
  description = "path to the credential object from GCP secret manager"
  nullable = false
}
variable "gcp_projectid" {
  type = string
  description = "project id from GCP associated with these resources"
  nullable = false
}


