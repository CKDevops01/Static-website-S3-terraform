# AWS S3 bucket resource

resource "aws_s3_bucket" "demo_bucket" {
  bucket = var.bucket_name # Name of the S3 bucket
}

# AWS S3 bucket ownership 

resource "aws_s3_bucket_ownership_controls" "owner" {
  bucket = aws_s3_bucket.demo_bucket.id
  rule {
    object_ownership = var.bucket_owner
  }
}

# AWS S3 bucket public access

resource "aws_s3_bucket_public_access_block" "pub-access" {
  bucket = aws_s3_bucket.demo_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}


# AWS S3 bucket ACL resource

resource "aws_s3_bucket_acl" "bucketacl" {
  depends_on = [
    aws_s3_bucket_ownership_controls.owner,
    aws_s3_bucket_public_access_block.pub-access,
  ]

  bucket = aws_s3_bucket.demo_bucket.id
  acl    = "public-read"
}



# S3 bucket policy

resource "aws_s3_bucket_policy" "host_bucket_policy" {
  bucket = aws_s3_bucket.demo_bucket.id # ID of the S3 bucket

  # Policy JSON for allowing public read access
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : "*",
        "Action" : "s3:GetObject",
        "Resource" : "arn:aws:s3:::${var.bucket_name}/*"
      }
    ]
  })
}

# https://registry.terraform.io/modules/hashicorp/dir/template/latest

module "template_files" {
  source = "hashicorp/dir/template"

  base_dir = "${path.module}/Web-Files"
}





resource "aws_s3_bucket_website_configuration" "web-config" {
  bucket = aws_s3_bucket.demo_bucket.id # ID of the S3 bucket

  # Configuration for the index document
  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }

}

# AWS S3 object resource for hosting bucket files

resource "aws_s3_object" "Bucket_files" {
  bucket = aws_s3_bucket.demo_bucket.id # ID of the S3 bucket

  for_each     = module.template_files.files
  key          = each.key
  content_type = each.value.content_type

  source  = each.value.source_path
  content = each.value.content

  # ETag of the S3 object
  etag = each.value.digests.md5
}





#   for_each = fileset("${path.module}/Web-Files", "*")
#   key      = each.value
#   source   = "${path.module}/Web-Files/${each.value}"

#   etag = filemd5("${path.module}/Web-Files/${each.value}")
# }
