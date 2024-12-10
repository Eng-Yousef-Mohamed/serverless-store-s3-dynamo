##### Creating a Random String #####
resource "random_string" "random" {
  length = 6
  special = false
  upper = false
} 

##### Creating an S3 Bucket #####
resource "aws_s3_bucket" "bucket" {
  bucket = "myshop-website-${random_string.random.result}"
  force_destroy = true
}

resource "aws_s3_bucket_website_configuration" "blog" {
  bucket = aws_s3_bucket.bucket.id
  index_document {
    suffix = "web.html"
  }
}

resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket = aws_s3_bucket.bucket.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

##### will upload all the files present under HTML folder to the S3 bucket #####
resource "aws_s3_object" "upload_object" {
  bucket        = aws_s3_bucket.bucket.id
  key           = "web.html"
  source        = "./web.html"
  content_type  = "text/html"
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        //Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.bucket.arn}/*"

      },
    ]
  })
}

output "s3_website_endpoint" {
  value = aws_s3_bucket_website_configuration.blog.website_endpoint
  description = "The URL of the S3 website"
}