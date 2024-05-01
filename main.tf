terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.47.0"
    }

    null = {
      source  = "hashicorp/null"
      version = "~> 3.2.2"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

locals {
  kb_embedded_model_arn = "arn:aws:bedrock:${data.aws_region.current.name}::foundation-model/amazon.titan-embed-text-v1"
  kb_vector_database_collection_arn = "arn:aws:aoss:us-east-1:916647378004:collection/hr27ub9s4idncrqg6ysa"
}
