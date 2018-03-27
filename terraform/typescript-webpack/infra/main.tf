variable "region" {
  default = "eu-west-1"
}

provider "aws" {
  region = "${var.region}"
}

data "aws_caller_identity" "current" {}

data "archive_file" "archive" {
  type        = "zip"
  source_dir  = "./../dist/"
  output_path = "./../deploy-package.zip"
}

resource "aws_lambda_function" "typescript-webpack" {
  function_name = "typescript-webpack"
  handler       = "index.controller"
  runtime       = "nodejs6.10"
  role          = "${aws_iam_role.typescript-webpack_exec.arn}"
  timeout       = 10

  filename         = "${data.archive_file.archive.output_path}"
  source_code_hash = "${base64sha256(file("${data.archive_file.archive.output_path}"))}"
  publish          = true
}

resource "aws_iam_role" "typescript-webpack_exec" {
  name = "typescriptterraform_exec"

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

resource "aws_iam_policy" "lambda_logging" {
  name        = "typescript-webpack_logging"
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
  role       = "${aws_iam_role.typescript-webpack_exec.name}"
  policy_arn = "${aws_iam_policy.lambda_logging.arn}"
}

####

#### Gateway:

resource "aws_api_gateway_rest_api" "typescript-webpack" {
  name        = "typescript-webpack"
  description = "typescript-webpack Application Example"
}

####

### Feature1 - GET start

resource "aws_api_gateway_resource" "hello" {
  rest_api_id = "${aws_api_gateway_rest_api.typescript-webpack.id}"
  parent_id   = "${aws_api_gateway_rest_api.typescript-webpack.root_resource_id}"
  path_part   = "hello"
}

resource "aws_api_gateway_method" "hello" {
  rest_api_id   = "${aws_api_gateway_rest_api.typescript-webpack.id}"
  resource_id   = "${aws_api_gateway_resource.hello.id}"
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda" {
  rest_api_id = "${aws_api_gateway_rest_api.typescript-webpack.id}"
  resource_id = "${aws_api_gateway_method.hello.resource_id}"
  http_method = "${aws_api_gateway_method.hello.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.typescript-webpack.invoke_arn}"
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.typescriptterraform.arn}"
  principal     = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${aws_api_gateway_deployment.typescript-webpack.execution_arn}/*/*"
}

### Feature1 - GET end

resource "aws_api_gateway_deployment" "typescript-webpack" {
  depends_on = [
    "aws_api_gateway_integration.lambda",
  ]

  rest_api_id = "${aws_api_gateway_rest_api.typescript-webpack.id}"
  stage_name  = "test"
}

output "base_url" {
  value = "${aws_api_gateway_deployment.typescript-webpack.invoke_url}"
}
