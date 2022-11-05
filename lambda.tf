# lambda.tf | Lambda Configuration

data "aws_iam_policy_document" "lambda_task_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_execution_role" {
  name               = "${var.app_name}-lambda-execution-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_task_policy.json
  tags = {
    Name        = "${var.app_name}-lambda-execution-iam-role"
    Environment = var.app_environment
  }
}

resource "aws_iam_policy" "lambda_policy" {
  name        = "${var.app_name}-lambda-policy"
  description = "Lambda Policy for S3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:PutObject",
        ]
        Effect   = "Allow"
        Resource = "arn:aws:s3:::${var.app_name}-excel/*"
      },
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect   = "Allow",
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Action = [
          "kms:DescribeKey",
          "kms:GenerateDataKey",
          "kms:Decrypt"
        ],
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

resource "aws_lambda_function" "lambda_upload" {
  filename         = "lambda_upload.zip"
  function_name    = "lambda_upload"
  role             = aws_iam_role.lambda_execution_role.arn
  handler          = "lambda_function.lambda_upload"
  source_code_hash = filebase64sha256("lambda_upload.zip")
  runtime          = "python3.9"

  environment {
    variables = {
      BUCKET_NAME = "${var.app_name}-excel"
    }
  }
}

resource "aws_lambda_function_url" "lambda_function_url" {
  function_name      = aws_lambda_function.lambda_upload.function_name
  authorization_type = "NONE"

  cors {
    allow_origins = ["https://itsag2t4.com", "http://localhost:8000"]
    allow_methods = ["POST"]
    allow_headers = ["*"]
    max_age       = 86400
  }
}
