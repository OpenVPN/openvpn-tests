#
# Automatically stop EC2 instances every night
#
# https://github.com/diodonfrost/terraform-aws-lambda-scheduler-stop-start
#
module "stop_ec2_instance" {
  source                         = "github.com/diodonfrost/terraform-aws-lambda-scheduler-stop-start?ref=4.5.0"
  name                           = "ec2_stop"
  # See https://docs.aws.amazon.com/lambda/latest/dg/services-cloudwatchevents-expressions.html
  cloudwatch_schedule_expression = "cron(30 19 * * ? *)"
  schedule_action                = "stop"
  autoscaling_schedule           = "false"
  documentdb_schedule            = "false"
  ec2_schedule                   = "true"
  ecs_schedule                   = "false"
  rds_schedule                   = "false"
  redshift_schedule              = "false"
  cloudwatch_alarm_schedule      = "false"
  scheduler_tag                  = {
    key   = "tostop"
    value = "true"
  }
}
