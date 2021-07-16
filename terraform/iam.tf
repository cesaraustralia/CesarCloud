# IAM role for accessing ECR withing EC2
resource "aws_iam_role" "ec2_ecr_access_role" {
  name               = "ecr-role"
  assume_role_policy = <<EOF
  {
   "Version": "2012-10-17",
   "Statement": [
     {
       "Action": "sts:AssumeRole",
       "Principal": {
         "Service": "ec2.amazonaws.com"
       },
       "Effect": "Allow",
       "Sid": ""
     }
   ]
  }
  EOF
}


# The IAM policy to give EC2 access to ECR
resource "aws_iam_policy" "ecr_access_policy" {
  name        = "ecr-assess-policy"
  description = "The IAM policy to give EC2 access to ECR"
  policy      = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowAll",
            "Effect": "Allow",
            "Action": [
                "ecr:*"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}


resource "aws_iam_policy_attachment" "ecr_policy_attach" {
  name       = "ecr-policy-attachment"
  roles      = [aws_iam_role.ec2_ecr_access_role.name]
  policy_arn = aws_iam_policy.ecr_access_policy.arn
}

# aws_instance.ec2.arn