data "aws_iam_policy_document" "allow_describe_regions" {
  statement {
    effect    = "Allow"
    actions   = ["ecs:DescribeRegions"]
    resources = ["*"]
  }
}

module "describe_regions_for_ec2" {
  source     = "./iam_role"
  name       = "describe-regions-for-ec2"
  identifier = "ec2.amazonaws.com"
  policy     = "${data.aws_iam_policy_document.allow_describe_regions.json}"
}

resource "aws_s3_bucket" "alb_log" {
  bucket = "alb-log-zissen-terraform"
  lifecycle_rule {
    enabled = true
    expiration {
      days = "180"
    }
  }
}

resource "aws_s3_bucket_policy" "alb_log" {
  bucket = "${aws_s3_bucket.alb_log.id}"
  policy = "${data.aws_iam_policy_document.alb_log.json}"
}

data "aws_iam_policy_document" "alb_log" {
  statement {
    effect    = "Allow"
    actions   = ["s3:PutObject"]
    resources = ["arn:aws:s3:::${aws_s3_bucket.alb_log.id}/*"]
    principals {
      type        = "AWS"
      identifiers = ["582318560864"] # AWSが管理しているアカウント.リージョンごとに固定
    }
  }
}
