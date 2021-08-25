# IAM role for accessing resources within EC2
resource "aws_iam_role" "ec2_access_role" {
  name               = "ec2-access-role"
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

  tags = {
    Name = "cesar-server"
  }
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
            "Resource": "*"
        }
    ]
}
  EOF
}

# The IAM policy to give EC2 access to S3 buckets
resource "aws_iam_policy" "s3_access_policy" {
  name        = "s3-assess-policy"
  description = "The IAM policy to give EC2 access to S3"
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": "*"
        }
    ]
}
  EOF
}

# add the policy-1 to role
resource "aws_iam_policy_attachment" "ecr_policy_attach" {
  name       = "ecr-policy-attachment"
  roles      = [aws_iam_role.ec2_access_role.name]
  policy_arn = aws_iam_policy.ecr_access_policy.arn
}

# add the policy-2 to role
resource "aws_iam_policy_attachment" "s3_policy_attach" {
  name       = "s3-policy-attachment"
  roles      = [aws_iam_role.ec2_access_role.name]
  policy_arn = aws_iam_policy.s3_access_policy.arn
}


# add the role (with policies attached to it) to the ec2 instance
resource "aws_iam_instance_profile" "ec2_profile" {
  name  = "ec2-profile"
  role = aws_iam_role.ec2_access_role.name

  tags = {
    Name = "cesar-server"
  }
}




# # This might be a better and simpler way to add policy

# resource "aws_iam_policy_attachment" "role-policy-attachment" {
#   role       = aws_iam_role.ec2_access_role.name
#   count      = "${length(var.iam_policy_arn)}"
#   policy_arn = "${var.iam_policy_arn[count.index]}"
# }


# # Define policy ARNs as list
# variable "iam_policy_arn" {
#   description = "IAM Policy to be attached to role"
#   type = "list"
# }

# # terraform vars
# iam_policy_arn = [
#   "arn:aws:iam::aws:policy/AmazonEC2FullAccess", 
#   "arn:aws:iam::aws:policy/AmazonS3FullAccess"
# ]

# # resource "aws_iam_role_policy_attachment" "role-policy-attachment" {
# #   role       = aws_iam_role.ec2_access_role.name
# #   count      = "${length(var.iam_policy_arn)}"
# #   policy_arn = "${var.iam_policy_arn[count.index]}"
# # }
