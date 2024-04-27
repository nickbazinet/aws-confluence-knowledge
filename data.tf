data "aws_vpc" "current" {
  tags = {
    Name = var.vpc_name
  }
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_subnet" "private1" {
  vpc_id = data.aws_vpc.current.id
  tags = {
    Name = var.private_subnet_name
  }
}
