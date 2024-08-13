provider "aws" {
  region = var.AWS_DEFAULT_REGION
}

resource "aws_iam_role" "lambda_role" {
  name = "${var.PROJECT_NAME}-lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/../../scripts/lambda.py"
  output_path = "${path.module}/lambda_function.zip"
}

resource "aws_lambda_function" "brewery_lambda" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "${var.PROJECT_NAME}-brewery-lambda"
  role             = aws_iam_role.lambda_role.arn
  handler          = "lambda.lambda_handler"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  runtime          = "python3.9"
  timeout          = 10
  memory_size      = 128
}

resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${aws_lambda_function.brewery_lambda.function_name}"
  retention_in_days = 3
}