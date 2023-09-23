provider "aws" {
  region = var.AWS_REGION
}

# VPC

resource "aws_vpc" "project-one" {
  cidr_block           = "10.20.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.project_name}-${var.project_env}-1"
  }
}

# subnets

resource "aws_subnet" "project-one" {
  vpc_id                  = aws_vpc.project-one.id
  cidr_block              = "10.20.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.project_name}-${var.project_env}-1"
  }
}

resource "aws_subnet" "project-one-eks" {
  vpc_id                  = aws_vpc.project-one.id
  cidr_block              = "10.20.2.0/24"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.project_name}-${var.project_env}-2"
  }
}

#internet gateway

resource "aws_internet_gateway" "project-one" {
  vpc_id = aws_vpc.project-one.id

  tags = {
    Name = "${var.project_name}-${var.project_env}"
  }
}

#routetable

resource "aws_route_table" "project-one" {
  vpc_id = aws_vpc.project-one.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.project-one.id
  }

  tags = {
    Name = "${var.project_name}-${var.project_env}"
  }
}

#subnet association

resource "aws_route_table_association" "project-one" {
  subnet_id      = aws_subnet.project-one.id
  route_table_id = aws_route_table.project-one.id

}

resource "aws_route_table_association" "project-one-eks" {
  subnet_id      = aws_subnet.project-one-eks.id
  route_table_id = aws_route_table.project-one.id

}

# s3_bucket

resource "aws_s3_bucket" "terraform_state" {
  bucket = "terraform-state-pranav"

  lifecycle {
    prevent_destroy = true
  }
}

# versioning

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# encription rule

resource "aws_s3_bucket_server_side_encryption_configuration" "remote" {
  bucket = aws_s3_bucket.terraform_state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}


# dynamodb 

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-state-locking"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

# remote backend

terraform {
  backend "s3" {
    bucket         = "terraform-state-pranav"
    key            = "terraform/s3/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-state-locking"
    encrypt        = true
  }
}

