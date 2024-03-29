# Convert integration name into snake case
locals {
  db_instance_identifier = join("", [for element in split("-", lower(var.db_instance_identifier)) : title(element)])
  opsgenie_responding_teams = setunion(var.opsgenie_responding_teams, toset([var.opsgenie_owner_team]))

  # Create alarm name based on the trigger condition (hopefully prevent duplicates)
  # (e.g. PaymentGatewayAverageApproximateNumberOfMessagesVisibleGreaterThanOrEqualToThreshold10000In5Periods)
  alarm_name = var.alarm_name == null ? "${local.db_instance_identifier}Rds${var.statistic}${var.metric_name}${var.comparison}${var.threshold}In${var.evaluation_periods}PeriodsOf${var.period}" : var.alarm_name
}

# Retrieve the requested Opsgenie users
data "opsgenie_user" "opsgenie_responding_users" {
  for_each = var.opsgenie_responding_users
  username = each.value
}

# Retrieve Opsgenie users
data "opsgenie_team" "opsgenie_responding_teams" {
  for_each = local.opsgenie_responding_teams
  name = each.value
}

# Retrieve Opsgenie users
data "opsgenie_team" "opsgenie_owner_team" {
  name = var.opsgenie_owner_team
}

# Get AWS account ID
data "aws_caller_identity" "default" {
}

# Create Opsgenie API integration
resource "opsgenie_api_integration" "opsgenie_integration" {
  name = "Terraform${data.aws_caller_identity.default.account_id}RdsIntegration${local.alarm_name}"
  type = "AmazonSns"
  owner_team_id = data.opsgenie_team.opsgenie_owner_team.id
  # Attach responders to the integration
  dynamic "responders" {
    for_each = var.opsgenie_responding_users
    content {
      type = "user"
      id = data.opsgenie_user.opsgenie_responding_users[responders.key].id
    }
  }
  dynamic "responders" {
    for_each = local.opsgenie_responding_teams
    content {
      type = "team"
      id = data.opsgenie_team.opsgenie_responding_teams[responders.key].id
    }
  }
  lifecycle {
    ignore_changes = [
      responders
    ]
  }
}

# Create an SNS topic for the alarm
resource "aws_sns_topic" "alarm" {
  name = local.alarm_name
  kms_master_key_id = var.sns_topic_kms_master_key_id
}

# Create HTTPS subscription from OpsGenie to the SNS topic
resource "aws_sns_topic_subscription" "message_age_alarm" {
  endpoint = "https://api.opsgenie.com/v1/json/amazonsns?apiKey=${opsgenie_api_integration.opsgenie_integration.api_key}"
  endpoint_auto_confirms = true
  protocol = "https"
  topic_arn = aws_sns_topic.alarm.arn
}

# Create CloudWatch alarm
resource "aws_cloudwatch_metric_alarm" "alarm" {
  namespace = "AWS/RDS"
  alarm_name = local.alarm_name
  comparison_operator = var.comparison
  metric_name = var.metric_name
  treat_missing_data = var.treat_missing_data
  evaluation_periods = var.evaluation_periods
  period = var.period
  statistic = var.statistic
  threshold = var.threshold
  # Link to the requested RDS instance
  dimensions = {
    DBInstanceIdentifier = var.db_instance_identifier
  }
  # Trigger the SNS topic on alarm
  alarm_actions = [
    aws_sns_topic.alarm.arn
  ]
}

# Create OpsGenie integration action on SNS topic creation
resource "opsgenie_integration_action" "alarm" {
  integration_id = opsgenie_api_integration.opsgenie_integration.id
  create {
    alias = local.alarm_name
    name = "Alarm Triggered"
    description = "The ${lower(var.statistic)} ${var.metric_name} was ${var.comparison} of ${var.threshold} for ${var.evaluation_periods} evaluation periods of ${var.period} seconds"
    message = var.description == null ? "The ${lower(var.statistic)} ${var.metric_name} was ${var.comparison} of ${var.threshold} for ${var.evaluation_periods} evaluation periods of ${var.period} seconds" : var.description
    ignore_responders_from_payload = true
    entity = var.opsgenie_entity
    user = var.opsgenie_user
    tags = setunion(toset([
      "RDS",
      var.metric_name
    ]), var.opsgenie_tags)
    priority = var.opsgenie_priority
    filter {
      type = "match-all"
    }
  }
  lifecycle {
    ignore_changes = [
      create[0].responders
    ]
  }
}
