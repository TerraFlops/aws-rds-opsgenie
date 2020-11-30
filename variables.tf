variable "ecs_task_name" {
  description = "Name of ECS task"
  type = string
}

variable "ecs_cluster_name" {
  description = "Name of ECS cluster"
  type = string
}

variable "alarm_name" {
  description = "Optional alarm name override, if none supplied will be procedurally generated based on conditions specified"
  type = string
  default = null
}

variable "metric_name" {
  type = string
  description = "CloudWatch ECS metric for alarm (e.g. CPUUtilization)"
}

variable "treat_missing_data" {
  type = string
  description = "How to treat missing data in CloudWatch metrics (defaults to 'notBreaching')"
  default = "notBreaching"
}

variable "comparison" {
  type = string
  description = "Comparison operator (e.g. GreaterThanOrEqualToThreshold)"
}

variable "period" {
  type = number
  description = "Evaluation period for alarm (seconds)"
}

variable "evaluation_periods" {
  type = number
  description = "Number of evaluation periods required before alarming"
}

variable "statistic" {
  type = string
  description = "Statistic for alarm (e.g. Maximum, Average)"
}

variable "threshold" {
  type = number
  description = "Threshold for alarm"
}

variable "opsgenie_tags" {
  type = set(string)
  description = "Optional set of tags to add to the OpsGenie alert"
  default = []
}

variable "opsgenie_entity" {
  type = string
  description = "Entity to associate with alarm (defaults to AmazonSns)"
  default = "AmazonSns"
}

variable "opsgenie_user" {
  type = string
  description = "User to associate with alarm (defaults to AmazonSns)"
  default = "AmazonSns"
}

variable "opsgenie_priority" {
  type = string
  description = "Opsgenie priority level for alarm"
}

variable "opsgenie_owner_team" {
  type = string
  description = "Team that owns the alarm in Opsgenie"
}

variable "opsgenie_integration_name" {
  type = string
  description = "Opsgenie integration name"
  default = null
}

variable "opsgenie_responding_users" {
  type = set(string)
  description = "Set of Opsgenie usernames to be added as responders"
  default = []
}

variable "opsgenie_responding_teams" {
  type = set(string)
  description = "Set of Opsgenie teams to be added as responders"
  default = []
}
