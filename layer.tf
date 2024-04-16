resource "null_resource" "lambda_layer" {
  triggers = {
    requirements = filesha1("${path.module}/requirements.txt")
  }
  provisioner "local-exec" {
    command = <<EOT
      ./${path.module}/layer_creation.sh 
    EOT
  }
}

resource "aws_s3_bucket" "atlassian_layer" {
  bucket = "mdf-eproc-atlassian-lambda-layer"
}

resource "aws_s3_object" "lambda_layer_zip" {
  bucket     = aws_s3_bucket.atlassian_layer.id
  key        = "lambda_layers/atlassian-layer.zip"
  source     = "atlassian_layer.zip"
  depends_on = [null_resource.lambda_layer]
}

resource "aws_lambda_layer_version" "atlassian" {
  s3_bucket           = aws_s3_bucket.atlassian_layer.id
  s3_key              = aws_s3_object.lambda_layer_zip.key
  layer_name          = "atlassian"
  compatible_runtimes = ["python3.12"]
  skip_destroy        = true
  depends_on          = [aws_s3_object.lambda_layer_zip]
}
