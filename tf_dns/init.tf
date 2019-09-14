provider "aws" {
  ## store key in env
  ## AWS_ACCESS_KEY_ID 
  ## AWS_SECRET_ACCESS_KEY
  region     = "${var.region}"
}