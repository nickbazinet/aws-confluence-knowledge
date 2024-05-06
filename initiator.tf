data "archive_file" "download_wiki_archive" {
  type        = "zip"
  output_path = "${path.module}/download_wiki.zip"

  source {
    content  = file("${path.module}/scripts/initiator.py")
    filename = "initiator.py"
  }

  source {
    content  = file("${path.module}/scripts/wiki.py")
    filename = "wiki.py"
  }

  source {
    content  = file("${path.module}/scripts/uploader.py")
    filename = "uploader.py"
  }

  source {
    content  = file("${path.module}/scripts/mdfconfluence.py")
    filename = "mdfconfluence.py"
  }
}

resource "aws_lambda_function" "initiator" {
  filename         = data.archive_file.download_wiki_archive.output_path
  function_name    = "wiki_downloader"
  handler          = "initiator.lambda_handler"
  source_code_hash = data.archive_file.download_wiki_archive.output_sha
  description      = "Lambda function that will download all the pages from a specific Confluence Space into an S3 bucket"
  role             = aws_iam_role.wiki_download.arn
  runtime          = "python3.12"
  timeout          = 600

  vpc_config {
    security_group_ids = [aws_security_group.wiki_knowledge_export.id]
    subnet_ids         = [data.aws_subnet.private1.id]
  }

  file_system_config {
    arn              = aws_efs_access_point.wiki_download.arn
    local_mount_path = "/mnt/efs-wiki-download"
  }

  environment {
    variables = {
      WIKI_SPACE            = var.confluence_spaces
      WIKI_URL              = var.confluence_url
      ACCESS_TOKEN          = var.access_token
      SECRET_TOKEN          = var.secret_token
      EFS_MOUNT_PATH        = "/mnt/efs-wiki-download"
      KNOWLEDGE_BASE_BUCKET = aws_s3_bucket.eproc_confluence_kb.bucket
      WIKI_SNS_TOPIC_ARN    = aws_sns_topic.confluence_knowledge_base_event.arn
    }
  }

  layers = [aws_lambda_layer_version.atlassian.arn]

  depends_on = [data.archive_file.download_wiki_archive, aws_iam_role.wiki_download]
}

resource "aws_security_group" "wiki_knowledge_export" {
  name   = "confluence-wiki-knowledge-export"
  vpc_id = data.aws_vpc.current.id
}

resource "aws_vpc_security_group_egress_rule" "wiki_export" {
  security_group_id = aws_security_group.wiki_knowledge_export.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_ingress_rule" "wiki_export" {
  security_group_id            = aws_security_group.wiki_knowledge_export.id
  referenced_security_group_id = aws_security_group.wiki_knowledge_export.id
  ip_protocol                  = "-1"
}
