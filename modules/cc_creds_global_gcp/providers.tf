terraform {
    required_providers {
        confluent = {
            source = "confluentinc/confluent"
            version = "1.42.0"
        }
        google-beta = ">= 4.77.0"
    }
}

provider "google-beta" {
  project = "" # replace with your project ID
}
