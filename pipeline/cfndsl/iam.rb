CloudFormation do
  Description("Dromedary demo - iam roles & policies and instance-profiles")
  AWSTemplateFormatVersion("2010-09-09")

  Resource("InstanceRole") do
    Type("AWS::IAM::Role")
    Property("AssumeRolePolicyDocument", {
      "Statement" => [
        {
          "Action"    => [
            "sts:AssumeRole"
          ],
          "Effect"    => "Allow",
          "Principal" => {
            "Service" => [
              "ec2.amazonaws.com"
            ]
          }
        }
      ]
    })
    Property("Path", "/")
    Property("Policies", [
      {
        "PolicyDocument" => {
          "Statement" => [
            {
              "Action"   => "*",
              "Effect"   => "Allow",
              "Resource" => "*"
            }
          ]
        },
        "PolicyName"     => "AllowAll"
      }
    ])
  end

  Resource("InstanceProfile") do
    Type("AWS::IAM::InstanceProfile")
    Property("Path", "/")
    Property("Roles", [
      Ref("InstanceRole")
    ])
  end

  Resource("CodeDeployTrustRole") do
    Type("AWS::IAM::Role")
    Property("AssumeRolePolicyDocument", {
      "Statement" => [
        {
          "Action"    => "sts:AssumeRole",
          "Effect"    => "Allow",
          "Principal" => {
            "Service" => [
              "codedeploy.us-east-1.amazonaws.com",
              "codedeploy.us-west-2.amazonaws.com"
            ]
          },
          "Sid"       => "1"
        }
      ]
    })
    Property("Path", "/")
    Property("Policies", [
      {
        "PolicyDocument" => {
          "Statement" => [
            {
              "Action"   => [
                "ec2:Describe*"
              ],
              "Effect"   => "Allow",
              "Resource" => [
                "*"
              ]
            },
            {
              "Action"   => [
                "autoscaling:CompleteLifecycleAction",
                "autoscaling:DeleteLifecycleHook",
                "autoscaling:DescribeLifecycleHooks",
                "autoscaling:DescribeAutoScalingGroups",
                "autoscaling:PutLifecycleHook",
                "autoscaling:RecordLifecycleActionHeartbeat"
              ],
              "Effect"   => "Allow",
              "Resource" => [
                "*"
              ]
            }
          ]
        },
        "PolicyName"     => "CodeDeployPolicy"
      }
    ])
  end

  Resource("CodePipelineTrustRole") do
    Type("AWS::IAM::Role")
    Property("AssumeRolePolicyDocument", {
      "Statement" => [
        {
          "Action"    => "sts:AssumeRole",
          "Effect"    => "Allow",
          "Principal" => {
            "Service" => [
              "codepipeline.amazonaws.com"
            ]
          },
          "Sid"       => "1"
        }
      ]
    })
    Property("Path", "/")
    Property("Policies", [
      {
        "PolicyDocument" => {
        "Statement" => [
          {
            "Action"   => [
              "s3:GetObject",
              "s3:GetObjectVersion",
              "s3:GetBucketVersioning"
            ],
            "Effect"   => "Allow",
            "Resource" => "*"
          },
          {
            "Action"   => [
              "s3:PutObject"
            ],
            "Effect"   => "Allow",
            "Resource" => [
              "arn:aws:s3:::codepipeline*",
              "arn:aws:s3:::dromedary*",
              "arn:aws:s3:::elasticbeanstalk*"
            ]
          },
          {
            "Action"   => [
              "codedeploy:CreateDeployment",
              "codedeploy:GetApplicationRevision",
              "codedeploy:GetDeployment",
              "codedeploy:GetDeploymentConfig",
              "codedeploy:RegisterApplicationRevision"
            ],
            "Effect"   => "Allow",
            "Resource" => "*"
          },
          {
            "Action"   => [
              "elasticbeanstalk:*",
              "ec2:*",
              "elasticloadbalancing:*",
              "autoscaling:*",
              "cloudwatch:*",
              "s3:*",
              "sns:*",
              "cloudformation:*",
              "rds:*",
              "sqs:*",
              "ecs:*",
              "iam:PassRole"
            ],
            "Effect"   => "Allow",
            "Resource" => "*"
          },
          {
            "Action"   => [
              "lambda:InvokeFunction",
              "lambda:ListFunctions"
            ],
            "Effect"   => "Allow",
            "Resource" => "*"
          }
        ],
        "Version"   => "2012-10-17"
        },
        "PolicyName"     => "CodePipelinePolicy"
      }
    ])
  end

  Output("StackName") do
    Value(Ref("AWS::StackName"))
  end

  Output("CodeDeployServiceRoleARN") do
    Description("The ARN of the Code Deploy Trust Role, which is needed to configure Code Deploy")
    Value(FnGetAtt("CodeDeployTrustRole", "Arn"))
  end

  Output("CodePipelineTrustRoleARN") do
    Description("The ARN of the Code Pipeline Trust Role, which is needed to configure Code Pipeline")
    Value(FnGetAtt("CodePipelineTrustRole", "Arn"))
  end

  Output("InstanceProfile") do
    Description("Name if instance-profile for Jenkins and application instances")
    Value(Ref("InstanceProfile"))
  end

  Output("InstanceRole") do
    Description("IAM Role for Jenkins and application instance profile")
    Value(Ref("InstanceRole"))
  end
end
