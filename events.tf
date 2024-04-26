resource "aws_sns_topic" "confluence_knowledge_base_event" {
  name = "confluence_knowledge_base_event"
}

resource "aws_sqs_queue" "confluence_knowledge_base_queue" {
  name = "confluence_knowledge_base_event"
}

resource "aws_sns_topic_subscription" "confluence_knowledge_base_queue_subscription" {
  topic_arn = aws_sns_topic.confluence_knowledge_base_event.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.confluence_knowledge_base_queue.arn
}
