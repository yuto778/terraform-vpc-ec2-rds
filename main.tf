provider "aws" {
  region = "ap-northeast-1"
}

resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "this" {
  bucket = "${var.bucket_name}-test-${random_id.suffix.hex}"
}
