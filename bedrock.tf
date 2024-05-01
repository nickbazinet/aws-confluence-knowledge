resource "aws_iam_role" "confluence_kb_service" {
  name = "bedrock-knowledge-base-diagrams"
  path = "/service-role/"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AmazonBedrockKnowledgeBaseTrustPolicy",
      "Effect": "Allow",
      "Principal": {
        "Service": "bedrock.amazonaws.com"
      },
      "Action": "sts:AssumeRole",
      "Condition": {
        "StringEquals": {
          "aws:SourceAccount": "${data.aws_caller_identity.current.account_id}"
        }
      }
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "bedrock_foundation_model" {
  role = aws_iam_role.confluence_kb_service.name
  policy_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/service-role/AmazonBedrockFoundationModelPolicyForKnowledgeBase_bedrock-knowledge-base-diagrams"
}

resource "aws_iam_role_policy_attachment" "bedrock_oss" {
  role = aws_iam_role.confluence_kb_service.name
  policy_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/service-role/AmazonBedrockOSSPolicyForKnowledgeBase_bedrock-knowledge-base-diagrams"
}

resource "aws_iam_role_policy_attachment" "bedrock_s3" {
  role = aws_iam_role.confluence_kb_service.name
  policy_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/service-role/AmazonBedrockS3PolicyForKnowledgeBase_bedrock-knowledge-base-diagrams"
}

resource "aws_bedrockagent_knowledge_base" "confluence" {
  name     = var.knowledge_base_name
  role_arn = aws_iam_role.confluence_kb_service.arn
  knowledge_base_configuration {
    vector_knowledge_base_configuration {
      embedding_model_arn = local.kb_embedded_model_arn  
    }
    type = "VECTOR"
  }
  storage_configuration {
    type = "OPENSEARCH_SERVERLESS"
    opensearch_serverless_configuration {
      collection_arn    = local.kb_vector_database_collection_arn
      vector_index_name = "bedrock-knowledge-base-default-index"
      field_mapping {
        vector_field   = "bedrock-knowledge-base-default-vector"
        text_field     = "AMAZON_BEDROCK_TEXT_CHUNK"
        metadata_field = "AMAZON_BEDROCK_METADATA"
      }
    }
  }
}
