variable "region" {
  default = "eu-west-1"
}

provider "aws" {
  region = "${var.region}"
}

data "aws_caller_identity" "current" {}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "./../src/index.js"
  output_path = "./../deploy-package.zip"
}

### Lamda START

resource "aws_lambda_function" "nodejsterraform" {
  function_name = "nodejsterraform"
  handler       = "index.handler"
  runtime       = "nodejs6.10"
  role          = "${aws_iam_role.nodejsterraform_exec.arn}"
  timeout       = 10

  filename         = "./../deploy-package.zip"
  source_code_hash = "${base64sha256(file("./../deploy-package.zip"))}"
  publish          = true
}

resource "aws_iam_role" "nodejsterraform_exec" {
  name = "nodejsterraform_exec"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

### Lamda END

### Logging START

resource "aws_iam_policy" "lambda_logging" {
  name        = "nodejsterraform_logging"
  path        = "/"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = "${aws_iam_role.nodejsterraform_exec.name}"
  policy_arn = "${aws_iam_policy.lambda_logging.arn}"
}

### Logging END

### Gateway START

resource "aws_api_gateway_rest_api" "nodejsterraform" {
  name        = "nodejsterraform"
  description = "nodejsterraform Application Example"
}

### Gateway END

### Feature1 - A simple GET method under a path

resource "aws_api_gateway_resource" "hello" {
  rest_api_id = "${aws_api_gateway_rest_api.nodejsterraform.id}"
  parent_id   = "${aws_api_gateway_rest_api.nodejsterraform.root_resource_id}"
  path_part   = "hello"
}

resource "aws_api_gateway_method" "hello" {
  rest_api_id   = "${aws_api_gateway_rest_api.nodejsterraform.id}"
  resource_id   = "${aws_api_gateway_resource.hello.id}"
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda" {
  rest_api_id = "${aws_api_gateway_rest_api.nodejsterraform.id}"
  resource_id = "${aws_api_gateway_method.hello.resource_id}"
  http_method = "${aws_api_gateway_method.hello.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.nodejsterraform.invoke_arn}"
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.nodejsterraform.arn}"
  principal     = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${aws_api_gateway_deployment.nodejsterraform.execution_arn}/*/*"
}

### Feature1 - end

### Deployment

resource "aws_api_gateway_deployment" "nodejsterraform" {
  depends_on = [
    "aws_api_gateway_integration.lambda",
  ]

  rest_api_id = "${aws_api_gateway_rest_api.nodejsterraform.id}"
  stage_name  = "test"
}

output "base_url" {
  value = "${aws_api_gateway_deployment.nodejsterraform.invoke_url}"
}
