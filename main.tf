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
  region = var.region 
}

locals {
  identifier = "${var.identifier}-"

  # AWS Bedrock
  kb_embedded_model_arn = "arn:aws:bedrock:${data.aws_region.current.name}::foundation-model/amazon.titan-embed-text-v1"
  kb_vector_database_collection_arn = "arn:aws:aoss:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:collection/hr27ub9s4idncrqg6ysa"

  # AWS Dynamodb
  metadata_dynamodb_table_name = "${local.identifier}-confluence-page_metadata"
}
