terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "uptime-tf-state-227421874679"
    key            = "envs/prod/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "uptime-tf-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      Project = "sre-uptime-monitor"
      Env     = "prod"
      Owner   = "you"
    }
  }
}

variable "region" {
  type    = string
  default = "us-east-1"
}
variable "env" {
  type    = string
  default = "prod"
}
variable "alert_email" {
  type = string
}


# Table for monitored targets
resource "aws_dynamodb_table" "targets" {
  name         = "uptime_targets"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "url"

  attribute {
    name = "url"
    type = "S"
  }
}

# Table for monitoring results
resource "aws_dynamodb_table" "results" {
  name         = "uptime_results"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "url"
  range_key    = "ts"

  attribute {
    name = "url"
    type = "S"
  }
  attribute {
    name = "ts"
    type = "N"
  }
}


# SNS topic for alerts
resource "aws_sns_topic" "alerts" {
  name = "uptime_alerts"
}

# Email subscription
resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

# Run monitoring every 5 minutes
resource "aws_cloudwatch_event_rule" "uptime_schedule" {
  name                = "uptime-schedule"
  description         = "Run uptime checks every 5 minutes"
  schedule_expression = "rate(5 minutes)"
}

resource "aws_iam_role" "lambda_exec" {
  name = "uptime_lambda_exec"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "lambda_sns_publish" {
  name = "lambda-sns-publish"
  role = aws_iam_role.lambda_exec.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["sns:Publish"]
        Resource = aws_sns_topic.alerts.arn
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "uptime_checker" {
  function_name = "uptime_checker"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "main.lambda_handler"
  runtime       = "python3.11"
  filename      = "${path.module}/checker.zip"
  source_code_hash = filebase64sha256("${path.module}/checker.zip")
  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.alerts.arn
    }
  }
}




# Permission for EventBridge to invoke Lambda (to be created later)
resource "aws_cloudwatch_event_target" "uptime_lambda_target" {
  rule      = aws_cloudwatch_event_rule.uptime_schedule.name
  target_id = "uptime-checker"
  arn       = aws_lambda_function.uptime_checker.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.uptime_checker.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.uptime_schedule.arn
}