provider "aws" {

}



# EC2 Instance Profile
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy" "AWSElasticBeanstalkMulticontainerDocker" {
  name = "AWSElasticBeanstalkMulticontainerDocker"
}

data "aws_iam_policy" "AWSElasticBeanstalkWebTier" {
  name = "AWSElasticBeanstalkWebTier"
}

data "aws_iam_policy" "AWSElasticBeanstalkWorkerTier" {
  name = "AWSElasticBeanstalkWorkerTier"
}

resource "aws_iam_instance_profile" "eb_profile" {
  name = "aws-elasticbeanstalk-ec2-role"
  role = aws_iam_role.eb_role.name
}

resource "aws_iam_role" "eb_role" {
  name               = "aws-elasticbeanstalk-ec2-role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  managed_policy_arns = [
    data.aws_iam_policy.AWSElasticBeanstalkMulticontainerDocker.arn,
    data.aws_iam_policy.AWSElasticBeanstalkWebTier.arn,
    data.aws_iam_policy.AWSElasticBeanstalkWorkerTier.arn
  ]
}

# EB
resource "aws_elastic_beanstalk_application" "tftest" {
  name        = "docker_react"
  description = "Sample application for Docker and Kubernetes Udemy Course"
}

resource "aws_elastic_beanstalk_environment" "tfenvtest" {
  name                = "Dockerreact-env"
  application         = aws_elastic_beanstalk_application.tftest.name
  solution_stack_name = "64bit Amazon Linux 2 v3.6.5 running Docker"
}