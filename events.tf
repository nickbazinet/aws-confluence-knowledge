resource "aws_sns_topic" "confluence_knowledge_base_event" {
  name = "confluence_knowledge_base_event"
}

resource "aws_sqs_queue" "confluence_knowledge_base_queue" {
  name = "confluence_knowledge_base_event"

  delay_seconds = 5

  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "Policy1596186813341"
    Statement = [
      {
        Sid       = "Stmt1596186812579"
        Effect    = "Allow"
        Principal = {
          Service = "sns.amazonaws.com"
        }
        Action = [
          "sqs:SendMessage",
          "sqs:SendMessageBatch"
        ]
        Resource = "arn:aws:sqs:us-east-1:${data.aws_caller_identity.current.account_id}:confluence_knowledge_base_event"
      },
    ]
  })
}

resource "aws_sns_topic_subscription" "confluence_knowledge_base_queue_subscription" {
  topic_arn = aws_sns_topic.confluence_knowledge_base_event.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.confluence_knowledge_base_queue.arn
}
