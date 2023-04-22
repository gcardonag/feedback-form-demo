locals {
  domain_name = "gcardona.me"
}

resource "aws_acm_certificate" "frontend" {
  domain_name       = "nerts2023.${local.domain_name}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_route53_zone" "frontend" {
  name         = local.domain_name
  private_zone = false
}

resource "aws_route53_record" "frontend_cert" {
  for_each = {
    for dvo in aws_acm_certificate.frontend.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.frontend.zone_id
}

resource "aws_acm_certificate_validation" "frontend" {
  certificate_arn         = aws_acm_certificate.frontend.arn
  validation_record_fqdns = [for record in aws_route53_record.frontend_cert : record.fqdn]
}

locals {
  website_origin_id = "S3-${aws_s3_bucket.frontend.bucket}"
}

resource "aws_cloudfront_origin_access_control" "frontend" {
  name                              = "feedback-form-demo-alpfa-nerts-2023"
  description                       = "S3 Bucket Access"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "frontend" {

  origin {
    domain_name              = aws_s3_bucket.frontend.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.frontend.id
    origin_id                = local.website_origin_id
  }

#   dynamic "custom_error_response" {
#     for_each = var.custom_error_response

#     content {
#       error_caching_min_ttl = custom_error_response.value.error_caching_min_ttl # 10
#       error_code            = custom_error_response.value.error_code # 404
#       response_code         = custom_error_response.value.response_code # 200
#       response_page_path    = custom_error_response.value.response_page_path # "/index.html"
#     }
#   }

  enabled             = true
  is_ipv6_enabled     = true
  price_class         = "PriceClass_100" # US & Europe Only
  default_root_object = "index.html"

  aliases = ["nerts2023.${local.domain_name}"]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.website_origin_id

    cache_policy_id          = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    origin_request_policy_id = "88a5eaf4-2fd4-4709-b370-b4c650ea3fcf"

    compress = true

    viewer_protocol_policy = "redirect-to-https"
  }

  ordered_cache_behavior {
    path_pattern = "/submit"
    allowed_methods = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods = ["GET", "HEAD"]
    target_origin_id = local.website_origin_id

    cache_policy_id          = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
    origin_request_policy_id = "33f36d7e-f396-46d9-90e0-52428a34d9dc"

    compress = true

    viewer_protocol_policy = "redirect-to-https"

    lambda_function_association {
      event_type = "viewer-request"
      include_body = true
      lambda_arn = aws_lambda_function.form_submit.qualified_arn
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Terraform   = true
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate_validation.frontend.certificate_arn
    minimum_protocol_version = "TLSv1.2_2021"
    ssl_support_method       = "sni-only"
  }
}