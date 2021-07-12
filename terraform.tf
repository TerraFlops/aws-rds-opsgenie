# Lock Terraform providers to specific versions to prevent upgrades causing breaking changes

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    opsgenie = {
      source = "opsgenie/opsgenie"
    }
    sumologic = {
      source = "SumoLogic/sumologic"
    }
  }
}
