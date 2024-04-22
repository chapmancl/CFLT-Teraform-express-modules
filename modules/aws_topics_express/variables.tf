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
  description = "path to the cluster level credential object from AWS secret manager"
  nullable = false
}
variable "aws_region" {
  type = string
  description = "region in AWS for resources"
  nullable = false
}


