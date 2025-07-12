provider "aws" {
  region = "ap-northeast-1"
}


resource "aws_s3_bucket" "state" {
  bucket = "vpc-ec2-rds-state-sample"
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "sse" {
  bucket = aws_s3_bucket.state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_dynamodb_table" "lock" {
  name         = "vpc-ec2-rds-statelock-sample"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}

output "aws_s3_bucket_state" {
  value = aws_s3_bucket.state.id
}

output "aws_dynamodb_table_lock" {
  value = aws_dynamodb_table.lock.arn
}
