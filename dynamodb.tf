# dynamodb.tf | DynamoDB Configuration

resource "aws_dynamodb_table" "users" {
  name         = "user"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "email"

  attribute {
    name = "email"
    type = "S"
  }

  attribute {
    name = "id"
    type = "S"
  }

  global_secondary_index {
    name            = "GSI1"
    hash_key        = "id"
    projection_type = "ALL"
  }
  # TODO: Mention this feature explicitly
  #   replica {
  #     region_name = var.aws_replica_region
  #   }

  tags = {
    Name        = "dynamodb-${var.app_name}-users"
    Environment = var.app_environment
  }
}

resource "aws_dynamodb_table" "organizations" {
  name         = "organization"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  # TODO: Mention this feature explicitly
  #   replica {
  #     region_name = var.aws_replica_region
  #   }

  tags = {
    Name        = "dynamodb-${var.app_name}-organizations"
    Environment = var.app_environment
  }
}
