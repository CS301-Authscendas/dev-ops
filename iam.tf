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
      #   {
      #     Action = [
      #       "s3:*",
      #     ],
      #     Effect = "Allow",
      #     Resource = [
      #       "arn:aws:s3:::${var.app_name}-secrets",
      #       "arn:aws:s3:::${var.app_name}-secrets/",
      #       "arn:aws:s3:::${var.app_name}-secrets/*"
      #     ]
      #   },
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject"
        ],
        Resource = [
          "arn:aws:s3:::${var.app_name}-secrets/*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "s3:GetBucketLocation"
        ],
        Resource = [
          "arn:aws:s3:::${var.app_name}"
        ]
      }
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
          "dynamodb:*",
        ],
        Effect   = "Allow",
        Resource = "*"
      },
      {
        Action = [
          "s3:*",
        ],
        Effect = "Allow",
        Resource = [
          "arn:aws:s3:::${var.app_name}-secrets",
          "arn:aws:s3:::${var.app_name}-secrets/",
          "arn:aws:s3:::${var.app_name}-secrets/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_role" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.ecs_task_role.arn
}
