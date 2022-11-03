# iam.tf | IAM Role Policies

data "aws_iam_policy_document" "ecs_task_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "${var.app_name}-ecs-execution-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_policy.json
  tags = {
    Name        = "${var.app_name}-iam-role"
    Environment = var.app_environment
  }
}

resource "aws_iam_policy" "ecs_task_execution_role" {
  name        = "${var.app_name}-ecs-task-execution"
  description = "Policy for S3 Secrets"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ],
        Effect   = "Allow",
        Resource = aws_s3_bucket.s3_bucket_secrets.arn
      },
      {
        Action = [
          "s3:DeleteObject",
          "s3:GetObject",
          "s3:PutObject",
          "s3:PutObjectAcl"
        ],
        Effect = "Allow",
        Resource = [
          "${aws_s3_bucket.s3_bucket_secrets.arn}/*"
        ]
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_secrets_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.ecs_task_execution_role.arn
}

resource "aws_iam_role" "ecs_task_role" {
  name               = "${var.app_name}-ecs-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_policy.json
  tags = {
    Name        = "${var.app_name}-iam-role"
    Environment = var.app_environment
  }
}

resource "aws_iam_policy" "ecs_task_role" {
  name        = "${var.app_name}-ecs-task-role"
  description = "Policy for DynamoDB"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "dynamodb:BatchGet*",
          "dynamodb:DescribeStream",
          "dynamodb:DescribeTable",
          "dynamodb:Get*",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:BatchWrite*",
          "dynamodb:Delete*",
          "dynamodb:Update*",
          "dynamodb:PutItem"
        ],
        Effect = "Allow",
        Resource = [
          aws_dynamodb_table.users.arn,
          aws_dynamodb_table.organizations.arn
        ]
      },
      {
        Action = [
          "kms:GetPublicKey",
          "kms:GetKeyRotationStatus",
          "kms:GetKeyPolicy",
          "kms:DescribeKey",
          "kms:ListKeyPolicies",
          "kms:ListResourceTags",
        ],
        Effect = "Allow",
        Resource = [
          aws_kms_key.jwt_signing_key.arn,
          aws_kms_key.spare_jwt_signing_key.arn
        ]
      },
      {
        Action = [
          "ses:GetTemplate",
        ],
        Effect = "Allow",
        Resource = [
          aws_ses_template.account_ready_email_template.arn,
          aws_ses_template.register_email_template.arn,
          aws_ses_template.twofa_email_template.arn,
          aws_ses_template.login_email_template.arn,
        ]
      },
      {
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ],
        Effect   = "Allow",
        Resource = aws_s3_bucket.s3_bucket_excel.arn
      },
      {
        Action = [
          "s3:DeleteObject",
          "s3:GetObject",
          "s3:PutObject",
          "s3:PutObjectAcl"
        ],
        Effect = "Allow",
        Resource = [
          "${aws_s3_bucket.s3_bucket_excel.arn}/*"
        ]
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_role" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.ecs_task_role.arn
}
