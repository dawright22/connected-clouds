#
# EKS Cluster Resources
#  * IAM Role to allow EKS service to manage other AWS services
#  * EC2 Security Group to allow networking traffic with EKS cluster
#  * EKS Cluster
#

resource "aws_iam_role" "terraform-multi-cloud-k8-demo-cluster" {
  name = "terraform-multi-cloud-k8-demo-cluster"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "terraform-multi-cloud-k8-demo-cluster-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.terraform-multi-cloud-k8-demo-cluster.name
}

resource "aws_iam_role_policy_attachment" "terraform-multi-cloud-k8-demo-cluster-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.terraform-multi-cloud-k8-demo-cluster.name
}

resource "aws_security_group" "terraform-multi-cloud-k8-demo-cluster" {
  name        = "terraform-multi-cloud-k8-demo-cluster"
  description = "Cluster communication with worker nodes"
  vpc_id      = aws_vpc.multi-cloud-k8-demo.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "terraform-eks-demo"
  }
}

resource "aws_security_group_rule" "demo-cluster-ingress" {
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow all to communicate with the cluster API Server"
  from_port         = 0
  protocol          = "tcp"
  security_group_id = aws_security_group.terraform-multi-cloud-k8-demo-cluster.id
  to_port           = 0
  type              = "ingress"
}


resource "aws_eks_cluster" "demo" {
  name     = var.cluster-name
  role_arn = aws_iam_role.terraform-multi-cloud-k8-demo-cluster.arn

  vpc_config {
    security_group_ids = [aws_security_group.terraform-multi-cloud-k8-demo-cluster.id]
    subnet_ids         = aws_subnet.multi-cloud-k8-demo[*].id
  }

  depends_on = [
    aws_iam_role_policy_attachment.terraform-multi-cloud-k8-demo-cluster-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.terraform-multi-cloud-k8-demo-cluster-AmazonEKSServicePolicy,
  ]

  provisioner "local-exec" {
    # Load credentials to local environment so subsequent kubectl commands can be run
    command = <<EOS
      aws eks --region ${var.aws_region} update-kubeconfig --name ${var.cluster-name}; 

EOS

  }
}






