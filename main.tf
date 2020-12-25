resource "aws_s3_bucket" "funcStore" {
  bucket_prefix = "simpleLambdaStore"
}

resource "aws_cloudwatch_log_group" "funcLogs" {
  name_prefix = "simpleLambdaLogs"
}

data "template_file" "policy_template" {
  template = "./lambda-policy-template.json"
  vars = {
    bucketName: aws_s3_bucket.funcStore.bucket
    logGroup: aws_cloudwatch_log_group.funcLogs.arn
  }
}

resource "aws_iam_role" "simpleLambdaRole" {
  assume_role_policy = data.template_file.policy_template.rendered
}

resource "aws_iam_role" "lambdaRole" {
  name_prefix = "simpleLambdaRole"
  assume_role_policy = ""
}

locals {
  funcFile = "${path.module}/func.zip"
}

resource "aws_lambda_function" "func" {
  function_name = var.functionName
  filename = local.funcFile
  source_code_hash = filebase64sha256(local.funcFile)

  handler = "index"
  role = aws_iam_role.lambdaRole.arn
  runtime = "nodejs12.x"

  environment {
    variables = {
      bucket = aws_s3_bucket.funcStore.arn
    }
  }
}