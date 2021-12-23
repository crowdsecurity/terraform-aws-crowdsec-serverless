data "aws_iam_policy_document" "ecs_task_execution_role" {
  version = "2012-10-17"
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com", ]
    }
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "crowdsec-lapi-exec-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_role.json
}

resource "aws_iam_role_policy" "lapi-cloudwatch-policy" {
  role   = aws_iam_role.ecs_task_execution_role.id
  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "autoscaling:Describe*",
                "logs:GetLogRecord",
                "logs:PutDestinationPolicy",
                "logs:StartQuery",
                "logs:StopQuery",
                "logs:TestMetricFilter",
                "logs:PutQueryDefinition",
                "logs:CreateLogGroup",
                "logs:GetLogDelivery",
                "logs:PutLogEvents",
                "logs:CreateLogDelivery",
                "logs:CreateExportTask",
                "logs:PutMetricFilter",
                "logs:CreateLogStream",
                "logs:GetQueryResults",
                "logs:UpdateLogDelivery",
                "logs:GetLogEvents",
                "logs:FilterLogEvents",
                "logs:PutSubscriptionFilter",
                "logs:PutRetentionPolicy",
                "logs:GetLogGroupFields",
                "logs:PutDestination",
                "logs:DescribeLogStreams"
            ],
            "Effect": "Allow",
            "Resource": "*"
        }
    ]
  }
  EOF
}

resource "aws_iam_role_policy" "lapi-exec-policy" {
  role   = aws_iam_role.ecs_task_execution_role.id
  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
            "ssmmessages:CreateControlChannel",
            "ssmmessages:CreateDataChannel",
            "ssmmessages:OpenControlChannel",
            "ssmmessages:OpenDataChannel"
            ],
            "Effect": "Allow",
            "Resource": "*"
        }
    ]
  }
  EOF
}