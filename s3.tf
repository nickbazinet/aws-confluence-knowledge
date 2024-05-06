resource "aws_s3_bucket" "eproc_confluence_kb" {
  bucket = "${local.identifier}confluence-spaces-kb"
}
