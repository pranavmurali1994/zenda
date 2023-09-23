resource "aws_instance" "project-one" {
  ami                         = var.ami
  instance_type               = var.instance_type
  key_name                    = var.key
  vpc_security_group_ids      = ["${aws_security_group.restrict.id}"]
  subnet_id                   = aws_subnet.project-one.id
  associate_public_ip_address = true
  for_each                    = toset(["jenkins-master", "ansible-server"])

  user_data = <<-EOF
    #!/bin/bash
    sudo yum update -y
    EOF

  tags = {
    Name = "${each.key}"
  }
}

#security group

resource "aws_security_group" "restrict" {
  name        = "Traffic_connection"
  description = "Traffic"
  vpc_id      = aws_vpc.project-one.id

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-${var.project_env}"
  }
}