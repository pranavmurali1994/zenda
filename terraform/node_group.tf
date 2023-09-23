resource "aws_instance" "kubectl-server" {
  ami                         = var.ami
  key_name                    = var.key
  instance_type               = var.instance_type
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.project-one.id
  vpc_security_group_ids      = [aws_security_group.restrict.id]
  user_data                   = <<-EOF
    #!/bin/bash
    sudo yum update -y
    EOF  
  tags = {
    Name = "kubectl"
  }

}

resource "aws_eks_node_group" "node-grp" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "project-one-node-group"
  node_role_arn   = aws_iam_role.worker.arn
  subnet_ids      = [aws_subnet.project-one.id, aws_subnet.project-one-eks.id]
  capacity_type   = "ON_DEMAND"
  disk_size       = "20"
  instance_types  = ["t2.small"]

  remote_access {
    ec2_ssh_key               = var.key
    source_security_group_ids = [aws_security_group.restrict.id]
  }

  labels = tomap({ env = "dev" })

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]
}