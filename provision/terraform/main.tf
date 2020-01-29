terraform {
  backend "s3" {
    bucket = "terraform-state-pour-moi"
    key    = "clyde/fightthetide"
    region = "us-east-1"
  }
}

data "aws_route53_zone" "primary" {
  name = "fighttheti.de."
}

module "website" {
  source         = "git::https://github.com/cloudposse/terraform-aws-s3-website.git?ref=0.8.0"
  namespace      = "clyde"
  stage          = "dev"
  name           = "app"
  hostname       = "www.fighttheti.de"
  parent_zone_id = data.aws_route53_zone.primary.zone_id
}

resource "null_resource" "remove_and_upload_to_s3" {
  provisioner "local-exec" {
    command = "aws s3 sync ${path.module}/../../html s3://${module.website.s3_bucket_name}"
  }
}

output "website" {
  value = module.website
}

output "debug" {
  value = data.aws_route53_zone.primary.zone_id
}