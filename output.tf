output "alarm_arn" {
  value = aws_cloudwatch_metric_alarm.alarm.arn
}

output "alarm_name" {
  value = aws_cloudwatch_metric_alarm.alarm.alarm_name
}

output "sns_topic_arn" {
  value = aws_sns_topic.alarm.arn
}

output "sns_topic_name" {
  value = aws_sns_topic.alarm.name
}

output "opsgenie_api_integration_name" {
  value = opsgenie_api_integration.opsgenie_integration.name
}

output "opsgenie_api_integration_id" {
  value = opsgenie_api_integration.opsgenie_integration.id
}

output "opsgenie_api_key" {
  value = opsgenie_api_integration.opsgenie_integration.api_key
}
