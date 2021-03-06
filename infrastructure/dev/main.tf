variable "aws_region" {}

variable "apex_environment" {}

variable "apex_function_hello" {}

/**
 * resources
 */
resource "aws_api_gateway_rest_api" "api" {
  name        = "apex-node-kit-api"
  description = "api for apex-node-kit"
}

resource "aws_api_gateway_resource" "hello" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  parent_id   = "${aws_api_gateway_rest_api.api.root_resource_id}"
  path_part   = "hello"
}

module "hello-post" {
  source          = "./api-gateway-method"
  method          = "POST"
  rest_api_id     = "${aws_api_gateway_rest_api.api.id}"
  parent_id       = "${aws_api_gateway_rest_api.api.root_resource_id}"
  resource_id     = "${aws_api_gateway_resource.hello.id}"
  aws_region      = "${var.aws_region}"
  lambda_function = "${var.apex_function_hello}"
}

module "deploy" {
  source      = "./api-gateway-deploy"
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  stage_name  = "${var.apex_environment}"
  depends_id  = "${module.hello-post.id}"
}

/**
 * outputs
 */
output "url" {
  value = "https://${aws_api_gateway_rest_api.api.id}.execute-api.${var.aws_region}.amazonaws.com/${var.apex_environment}"
}
