terraform {
  backend "s3" {
    bucket = "jg-tf-state"
    key    = "terraform.tfstate"
    region = "ap-southeast-2"
  }
}

provider "aws" {
  region  = "ap-southeast-2"
  version = "~> 2.52"
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

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

resource "aws_iam_role_policy_attachment" "execute_for_lambda" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "xray_for_lambda" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/AWSXrayWriteOnlyAccess"
}

resource "aws_lambda_function" "eat_my_shorts" {
  function_name = "eatmyshorts"


  handler     = "create_short"
  runtime     = "provided"
  memory_size = 128

  source_code_hash = filebase64sha256("../target/lambda/release/bootstrap.zip")
  filename         = "../target/lambda/release/bootstrap.zip"

  role = aws_iam_role.iam_for_lambda.arn

  environment {
    variables = {
      RUST_BACKTRACE = "1"
    }
  }
}
