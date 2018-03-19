variable "region" {
  default = "eu-west-1"
}

provider "aws" {
  region = "${var.region}"
}

data "aws_caller_identity" "current" {} # Not used, but will get the current identity/AWS account

### Lamda START

resource "aws_lambda_function" "dotnetterraform" {
  function_name = "dotnetterraform"
  handler       = "CsharpHandlers::AwsDotnetCsharp.Handler::Hello"
  runtime       = "dotnetcore2.0"
  role          = "${aws_iam_role.lambda_exec.arn}"
  timeout       = 10

  filename         = "./../deploy-package.zip"
  source_code_hash = "${base64sha256(file("./../deploy-package.zip"))}"
  publish          = true
}

resource "aws_lambda_function" "dotnetterraform2" {
  function_name = "dotnetterraform2"
  handler       = "CsharpHandlers::AwsDotnetCsharp.Handler2::Hello2"
  runtime       = "dotnetcore2.0"
  role          = "${aws_iam_role.lambda_exec.arn}"
  timeout       = 10

  filename         = "./../deploy-package.zip"
  source_code_hash = "${base64sha256(file("./../deploy-package.zip"))}"
  publish          = true
}

resource "aws_iam_role" "lambda_exec" {
  name = "serverless_example_lambda"

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

### Cloudwatch

resource "aws_iam_policy" "lambda_logging" {
  name        = "dotnetterraform_logging"
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
  role       = "${aws_iam_role.lambda_exec.name}"
  policy_arn = "${aws_iam_policy.lambda_logging.arn}"
}

####

### Gateway START

resource "aws_api_gateway_rest_api" "terraformlambda" {
  name        = "terraformlambda"
  description = "Terraform Serverless Application Example"
}

### Gateway END

### Feature1 - Simple GET method START

resource "aws_api_gateway_resource" "hello" {
  rest_api_id = "${aws_api_gateway_rest_api.terraformlambda.id}"
  parent_id   = "${aws_api_gateway_rest_api.terraformlambda.root_resource_id}"
  path_part   = "hello"
}

resource "aws_api_gateway_method" "hello" {
  rest_api_id   = "${aws_api_gateway_rest_api.terraformlambda.id}"
  resource_id   = "${aws_api_gateway_resource.hello.id}"
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda" {
  rest_api_id = "${aws_api_gateway_rest_api.terraformlambda.id}"
  resource_id = "${aws_api_gateway_method.hello.resource_id}"
  http_method = "${aws_api_gateway_method.hello.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.dotnetterraform.invoke_arn}"
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.dotnetterraform.arn}"
  principal     = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${aws_api_gateway_deployment.terraformlambda.execution_arn}/*/*"
}

### Feature1 - END

### Feature2 - Simple POST method START

resource "aws_api_gateway_resource" "hello2" {
  rest_api_id = "${aws_api_gateway_rest_api.terraformlambda.id}"
  parent_id   = "${aws_api_gateway_rest_api.terraformlambda.root_resource_id}"
  path_part   = "hello2"
}

resource "aws_api_gateway_method" "hello2" {
  rest_api_id   = "${aws_api_gateway_rest_api.terraformlambda.id}"
  resource_id   = "${aws_api_gateway_resource.hello2.id}"
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda2" {
  rest_api_id = "${aws_api_gateway_rest_api.terraformlambda.id}"
  resource_id = "${aws_api_gateway_method.hello2.resource_id}"
  http_method = "${aws_api_gateway_method.hello2.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.dotnetterraform.invoke_arn}"
}

### Features2 - end

### Feature 3 - A NESTED GET metod START

resource "aws_api_gateway_resource" "world" {
  rest_api_id = "${aws_api_gateway_rest_api.terraformlambda.id}"
  parent_id   = "${aws_api_gateway_resource.hello.id}"
  path_part   = "world"
}

resource "aws_api_gateway_method" "world" {
  rest_api_id   = "${aws_api_gateway_rest_api.terraformlambda.id}"
  resource_id   = "${aws_api_gateway_resource.world.id}"
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda3" {
  rest_api_id = "${aws_api_gateway_rest_api.terraformlambda.id}"
  resource_id = "${aws_api_gateway_method.world.resource_id}"
  http_method = "${aws_api_gateway_method.world.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.dotnetterraform.invoke_arn}"
}

### Feature 3 - END

### Feature 4 - A simple GET metod using another lambda

resource "aws_api_gateway_resource" "hello4" {
  rest_api_id = "${aws_api_gateway_rest_api.terraformlambda.id}"
  parent_id   = "${aws_api_gateway_rest_api.terraformlambda.root_resource_id}"
  path_part   = "hello4"
}

resource "aws_api_gateway_method" "hello4" {
  rest_api_id   = "${aws_api_gateway_rest_api.terraformlambda.id}"
  resource_id   = "${aws_api_gateway_resource.hello4.id}"
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda4" {
  rest_api_id = "${aws_api_gateway_rest_api.terraformlambda.id}"
  resource_id = "${aws_api_gateway_method.hello4.resource_id}"
  http_method = "${aws_api_gateway_method.hello4.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.dotnetterraform2.invoke_arn}"
}

resource "aws_lambda_permission" "apigw4" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.dotnetterraform2.arn}"
  principal     = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${aws_api_gateway_deployment.terraformlambda.execution_arn}/*/*"
}

### Feature 4 - END

### Feature 5 - A PROXY method START

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = "${aws_api_gateway_rest_api.terraformlambda.id}"
  parent_id   = "${aws_api_gateway_rest_api.terraformlambda.root_resource_id}"
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy" {
  rest_api_id   = "${aws_api_gateway_rest_api.terraformlambda.id}"
  resource_id   = "${aws_api_gateway_resource.proxy.id}"
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_proxy" {
  rest_api_id = "${aws_api_gateway_rest_api.terraformlambda.id}"
  resource_id = "${aws_api_gateway_method.proxy.resource_id}"
  http_method = "${aws_api_gateway_method.proxy.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.dotnetterraform.invoke_arn}"
}

# Unfortunately the proxy resource cannot match an empty path at the root of the API.
# To handle that, a similar configuration must be applied to the root resource that is built in to the REST API object
resource "aws_api_gateway_method" "proxy_root" {
  rest_api_id   = "${aws_api_gateway_rest_api.terraformlambda.id}"
  resource_id   = "${aws_api_gateway_rest_api.terraformlambda.root_resource_id}"
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_root" {
  rest_api_id = "${aws_api_gateway_rest_api.terraformlambda.id}"
  resource_id = "${aws_api_gateway_method.proxy_root.resource_id}"
  http_method = "${aws_api_gateway_method.proxy_root.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.dotnetterraform.invoke_arn}"
}

### Feature 5 - END

### Deployment START

# The different integrations need to be defined in depends_on or it's possible to experience and error of a method not having an integration
resource "aws_api_gateway_deployment" "terraformlambda" {
  depends_on = [
    "aws_api_gateway_integration.lambda",
    "aws_api_gateway_integration.lambda3",
    "aws_api_gateway_integration.lambda4",
    "aws_api_gateway_integration.lambda_proxy",
    "aws_api_gateway_integration.lambda_root",
  ]

  rest_api_id = "${aws_api_gateway_rest_api.terraformlambda.id}"
  stage_name  = "test"
}

output "base_url" {
  value = "${aws_api_gateway_deployment.terraformlambda.invoke_url}"
}

### Deployment END

