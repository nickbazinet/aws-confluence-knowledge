data "aws_iam_policy_document" "kms_policy" {
  policy_id = "cf-kb-key"

  statement {
    sid     = "Enable IAM User Permissions"
    actions = ["kms:*"]
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      ]
    }
    resources = ["*"]
  }

  statement {
    sid = "S3/EFS/Lambda/Logs Decrypt permission"
    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*"
    ]
    principals {
      type = "Service"
      identifiers = [
        "s3.amazonaws.com",
        "elasticfilesystem.amazonaws.com",
        "lambda.amazonaws.com",
        "delivery.logs.amazonaws.com",
        "logs.${data.aws_region.current.name}.amazonaws.com"
      ]
    }
    resources = ["*"]
  }
}

resource "aws_kms_key" "encryption_key" {
  description         = "This key is used for encrypting data related to the Wiki Exporter to Knowledge Base service."
  policy              = data.aws_iam_policy_document.kms_policy.json
  enable_key_rotation = true
}

resource "aws_kms_alias" "aws-wiki_kb" {
  name          = "alias/wiki-to-aws-kb"
  target_key_id = aws_kms_key.encryption_key.key_id
}
