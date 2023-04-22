data "aws_caller_identity" "current" {}

data "archive_file" "form_submit" {
  type             = "zip"
  source_dir       = "src_code/form-submit"
  output_file_mode = "0666"
  output_path      = "local_output/form-submit.zip"
}

resource "aws_lambda_function" "form_submit" {
  filename      = data.archive_file.form_submit.output_path
  function_name = "form-submit-nerts2023"
  role          = aws_iam_role.form_submit.arn
  handler       = "lambda_function.lambda_handler"
  publish       = true

  source_code_hash = filebase64sha256(data.archive_file.form_submit.output_path)

  runtime = "python3.9"

  tags = {
    Terraform = true
  }
}

resource "aws_iam_role" "form_submit" {
  name = "form-submit"
  path = "/service-role/"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [
            "lambda.amazonaws.com",
            "edgelambda.amazonaws.com"
        ]
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

data "aws_iam_policy" "AWSLambdaBasicExecutionRole" {
  path_prefix = "/service-role/"
  name        = "AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "form_submit" {
  role       = aws_iam_role.form_submit.name
  policy_arn = data.aws_iam_policy.AWSLambdaBasicExecutionRole.arn
}

resource "aws_iam_policy" "form_submit" {
  name = "DynamoDBAccess"
  path = "/"
  #   description = "My test policy"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "dynamodb:ListTables"
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "dynamodb:DescribeTable",
          "dynamodb:PutItem"
        ]
        Effect = "Allow"
        Resource = [
          aws_dynamodb_table.form_submit.arn
        ]
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "test_page_list_dynamodb_access" {
  role       = aws_iam_role.form_submit.name
  policy_arn = aws_iam_policy.form_submit.arn
}
