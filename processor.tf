data "archive_file" "processor_archive" {
  type        = "zip"
  output_path = "${path.module}/processor.zip"

  source {
    content  = file("${path.module}/scripts/processor.py")
    filename = "processor.py"
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

resource "aws_lambda_function" "lambda_wiki_event_processor" {
  filename         = data.archive_file.processor_archive.output_path
  function_name    = "wiki_event_processor"
  handler          = "processor.lambda_handler"
  source_code_hash = data.archive_file.processor_archive.output_sha
  description      = "Lambda function that will download a specific confluence page from a specific message payload"
  role             = aws_iam_role.wiki_download.arn
  runtime          = "python3.12"
  timeout          = 30
  reserved_concurrent_executions = 1

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
      WIKI_SPACE            = var.confluence_space
      WIKI_URL              = var.confluence_url
      ACCESS_TOKEN          = var.access_token
      SECRET_TOKEN          = var.secret_token
      EFS_MOUNT_PATH        = "/mnt/efs-wiki-download"
      KNOWLEDGE_BASE_BUCKET = aws_s3_bucket.eproc_confluence_kb.bucket
      WIKI_SNS_TOPIC_ARN    = aws_sns_topic.confluence_knowledge_base_event.arn
    }
  }

  layers = [aws_lambda_layer_version.atlassian.arn]

  depends_on = [data.archive_file.processor_archive, aws_iam_role.wiki_download]
}

resource "aws_lambda_permission" "sqs_invoke_kb_event_processor" {
  statement_id  = "AllowExecutionFromSQS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_wiki_event_processor.function_name
  principal     = "sqs.amazonaws.com"
  source_arn    = aws_sqs_queue.confluence_knowledge_base_queue.arn
}

resource "aws_lambda_event_source_mapping" "trigger_processor_from_queue" {
  event_source_arn = aws_sqs_queue.confluence_knowledge_base_queue.arn
  function_name    = aws_lambda_function.lambda_wiki_event_processor.arn
}
