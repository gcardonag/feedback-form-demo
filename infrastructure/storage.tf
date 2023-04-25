resource "aws_s3_bucket" "frontend" {
  bucket = "feedback-form-demo-alpfa-nerts-2023"
}

resource "aws_s3_bucket_policy" "frontend" {
  bucket = aws_s3_bucket.frontend.id
  policy = data.aws_iam_policy_document.frontend.json
}

data "aws_iam_policy_document" "frontend" {
  statement {
    sid = "AllowCloudFrontServicePrincipalReadOnly"

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "${aws_s3_bucket.frontend.arn}/*",
    ]

    condition {
      test     = "StringLike"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.frontend.arn]
    }
  }
}

resource "aws_dynamodb_table" "form_submit" {
  name           = "form-submit-nerts2023"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "requestId"

  attribute {
    name = "requestId"
    type = "S"
  }

  tags = {
    Terraform = true
  }
}
