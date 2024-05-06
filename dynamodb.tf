resource "aws_dynamodb_table" "pages_metadata" {
  name           = local.metadata_dynamodb_table_name 
  billing_mode   = "PAY_PER_REQUEST"  
  hash_key       = "page_id"
  range_key      = "last_retrieval_timestamp"
  read_capacity  = 5  
  write_capacity = 5  

  attribute {
    name = "page_id"
    type = "S"  
  }

  attribute {
    name = "last_retrieval_timestamp"
    type = "N"  
  }

  attribute {
    name = "page_space"
    type = "S"
  }

  global_secondary_index {
    name               = "last_retrieval_timestamp_index"
    hash_key           = "last_retrieval_timestamp"
    range_key          = "page_space"
    projection_type    = "ALL"
    read_capacity      = 5  
    write_capacity     = 5  
  }
}
