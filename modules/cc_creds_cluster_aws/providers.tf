terraform {
  required_providers {
    confluent = {
      source = "confluentinc/confluent"
      version = "1.42.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}



