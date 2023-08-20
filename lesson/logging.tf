# Log bucket
resource "aws_s3_bucket" "cloudwatch_logs" {
  bucket = "YOUR-CLOUDWATCH-LOGS-BUCKET-NAME"
}
resource "aws_s3_bucket_lifecycle_configuration" "cloudwatch_logs_lifecycle" {
  bucket = aws_s3_bucket.cloudwatch_logs.bucket

  rule {
    id      = "someUniqueIDForTheRule"
    status  = "Enabled"
    expiration {
      days = 180
    }
  }
}

# Kinesis Data Firehose
## IAM role
data "aws_iam_policy_document" "kinesis_data_firehose" {
  statement {
    effect = "Allow"

    actions = [
      "a3:AbortMultipartUpload",
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:PutObject",
    ]

    resources = [
      "arn:aws:s3:::${aws_s3_bucket.cloudwatch_logs.id}",
      "arn:aws:s3:::${aws_s3_bucket.cloudwatch_logs.id}/*",
    ]
  }
}

module "kinesis_data_firehose_role" {
  source     = "./iam_role"
  name       = "YOUR-KINESIS-DATA-FIREHOSE-ROLE-NAME"
  identifier = "firehose.amazonaws.com"
  policy     = data.aws_iam_policy_document.kinesis_data_firehose.json
}

## Kinesis stream
resource "aws_kinesis_firehose_delivery_stream" "example" {
  name        = "YOUR-KINESIS-STREAM-NAME"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn   = module.kinesis_data_firehose_role.iam_role_arn
    bucket_arn = aws_s3_bucket.cloudwatch_logs.arn
    prefix     = "ecs-scheduled-tasks/YOUR-LOGS-PREFIX"
  }
}

# CloudWatch Logs
# IAM role
data "aws_iam_policy_document" "cloudwatch_logs" {
  statement {
    effect    = "Allow"
    actions   = ["firehose:*"]
    resources = [
      "arn:aws:firehose:ap-northeast-1:810160683974:deliverystream/YOUR-KINESIS-STREAM-NAME",
      "arn:aws:iam::*:role/cloudwatch-logs"
    ]
  }
}

module "cloudwatch_logs_role" {
  source     = "./iam_role"
  name       = "YOUR-CLOUDWATCH-LOGS-ROLE-NAME"
  identifier = "logs.ap-northeast-1.amazonaws.com"
  policy     = data.aws_iam_policy_document.cloudwatch_logs.json
}

# Subscription filter
resource "aws_cloudwatch_log_subscription_filter" "example" {
  name            = "YOUR-SUBSCRIPTION-FILTER-NAME"
  log_group_name  = aws_cloudwatch_log_group.for_ecs_scheduled_tasks.name
  destination_arn = aws_kinesis_firehose_delivery_stream.example.arn
  filter_pattern  = "[]"
  role_arn        = module.cloudwatch_logs_role.iam_role_arn
}
