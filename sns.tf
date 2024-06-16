# Create SNS Topic
resource "aws_sns_topic" "app_notifications" {
  name = format("%s-app-notifications", var.project)

  tags = {
    Name    = "${format("%s-app-notifications", var.project)}"
    Project = var.project
  }
}

# Create SNS Subscriptions
resource "aws_sns_topic_subscription" "app_notifications_sahil" {
  topic_arn = aws_sns_topic.app_notifications.arn
  protocol  = "email"
  endpoint  = "sahil@32nd.com"
}

resource "aws_sns_topic_subscription" "app_notifications_vikas" {
  topic_arn = aws_sns_topic.app_notifications.arn
  protocol  = "email"
  endpoint  = "vikas@32nd.com"
}