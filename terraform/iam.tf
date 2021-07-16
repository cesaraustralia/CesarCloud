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
            "Effect": "Allow",
            "Action": [
                "ecr:*"
            ],
            "Principal": {
              "AWS": "851347699251"
            },
            "Resource": "*"
        }
    ]
}
  EOF
}

# add the policy to role
resource "aws_iam_policy_attachment" "ecr_policy_attach" {
  name       = "ecr-policy-attachment"
  roles      = [aws_iam_role.ec2_ecr_access_role.name]
  policy_arn = aws_iam_policy.ecr_access_policy.arn
}

# add the role and policy to ec2 instance
resource "aws_iam_instance_profile" "ec2_profile" {
  name  = "ec2-profile"
  role = aws_iam_role.ec2_ecr_access_role.name
}
