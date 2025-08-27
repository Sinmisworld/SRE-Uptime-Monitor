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

# Permission for EventBridge to invoke Lambda (to be created later)
# resource "aws_cloudwatch_event_target" "uptime_lambda_target" {
#   rule      = aws_cloudwatch_event_rule.uptime_schedule.name
#   target_id = "uptime-checker"
#   arn       = aws_lambda_function.uptime_checker.arn
# }
