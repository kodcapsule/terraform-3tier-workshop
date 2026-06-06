resource "aws_s3_bucket" "tf-state-bucket" {
  bucket = "tf-state-bucket-kuseh-101"

  lifecycle {
    prevent_destroy = true
  }

}


resource "aws_s3_bucket_versioning" "tf-state-bucket-versioning" {
  bucket = aws_s3_bucket.tf-state-bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}


resource "aws_s3_bucket_server_side_encryption_configuration" "tf-state-bucket-encryption" {
  bucket = aws_s3_bucket.tf-state-bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "tf-state-bucket-public-access-block" {
  bucket                  = aws_s3_bucket.tf-state-bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}