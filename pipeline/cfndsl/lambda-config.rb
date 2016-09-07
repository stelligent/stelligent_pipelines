CloudFormation do
  Description("Creates Lambda functions which enable the lookup of 'upstream' Stack Outputs and Resources from within a 'downstream' CloudFormation template (without having to use code external to the template) ")
  AWSTemplateFormatVersion("2010-09-09")

  Resource("iamMFAFunction") do
    Type("AWS::Lambda::Function")
    Property("Handler", "iam-user-mfa.handler")
    Property("Role", FnGetAtt("lambdaExecutionRole", "Arn"))
    Property("Code", {
      "S3Bucket" => FnJoin("", [
        "dromedary-",
        Ref("AWS::AccountId")
      ]),
      "S3Key"    => "lambda/config-rules.zip"
    })
    Property("Runtime", "nodejs")
    Property("Timeout", "5")
  end

  Resource("iamUserInlinePolicyFunction") do
    Type("AWS::Lambda::Function")
    Property("Handler", "iam-user-inlinepolicy.handler")
    Property("Role", FnGetAtt("lambdaExecutionRole", "Arn"))
    Property("Code", {
      "S3Bucket" => FnJoin("", [
        "dromedary-",
        Ref("AWS::AccountId")
      ]),
      "S3Key"    => "lambda/config-rules.zip"
    })
    Property("Runtime", "nodejs")
    Property("Timeout", "5")
  end

  Resource("iamUserManagedPolicyFunction") do
    Type("AWS::Lambda::Function")
    Property("Handler", "iam-user-managedpolicy.handler")
    Property("Role", FnGetAtt("lambdaExecutionRole", "Arn"))
    Property("Code", {
      "S3Bucket" => FnJoin("", [
        "dromedary-",
        Ref("AWS::AccountId")
      ]),
      "S3Key"    => "lambda/config-rules.zip"
    })
    Property("Runtime", "nodejs")
    Property("Timeout", "5")
  end

  Resource("ec2SecGrpCidrIngressFunction") do
    Type("AWS::Lambda::Function")
    Property("Handler", "ec2-secgrp-cidr-ingress.handler")
    Property("Role", FnGetAtt("lambdaExecutionRole", "Arn"))
    Property("Code", {
      "S3Bucket" => FnJoin("", [
        "dromedary-",
        Ref("AWS::AccountId")
      ]),
      "S3Key"    => "lambda/config-rules.zip"
    })
    Property("Runtime", "nodejs")
    Property("Timeout", "5")
  end

  Resource("ec2SecGrpCidrEgressFunction") do
    Type("AWS::Lambda::Function")
    Property("Handler", "ec2-secgrp-cidr-egress.handler")
    Property("Role", FnGetAtt("lambdaExecutionRole", "Arn"))
    Property("Code", {
      "S3Bucket" => FnJoin("", [
        "dromedary-",
        Ref("AWS::AccountId")
      ]),
      "S3Key"    => "lambda/config-rules.zip"
    })
    Property("Runtime", "nodejs")
    Property("Timeout", "5")
  end

  Resource("ec2VPCRule") do
    Type("AWS::Config::ConfigRule")
    Property("ConfigRuleName", "ConSec-EC2-VPC-Rule")
    Property("Description", "Checks whether your EC2 instances belong to a virtual private cloud (VPC).")
    Property("Scope", {
      "ComplianceResourceTypes" => []
    })
    Property("Source", {
      "Owner"            => "AWS",
      "SourceDetails"    => [],
      "SourceIdentifier" => "INSTANCES_IN_VPC"
    })
  end

  Resource("ec2SSHRule") do
    Type("AWS::Config::ConfigRule")
    Property("ConfigRuleName", "ConSec-EC2-SSH-Rule")
    Property("Description", "Checks whether security groups that are in use disallow unrestricted incoming SSH traffic.")
    Property("Scope", {
      "ComplianceResourceTypes" => []
    })
    Property("Source", {
      "Owner"            => "AWS",
      "SourceDetails"    => [],
      "SourceIdentifier" => "INCOMING_SSH_DISABLED"
    })
  end

  Resource("ec2EncryptionRule") do
    Type("AWS::Config::ConfigRule")
    Property("ConfigRuleName", "ConSec-EC2-Encryption-Rule")
    Property("Description", "Checks whether EBS volumes that are in an attached state are encrypted.")
    Property("Scope", {
      "ComplianceResourceTypes" => []
    })
    Property("Source", {
      "Owner"            => "AWS",
      "SourceDetails"    => [],
      "SourceIdentifier" => "ENCRYPTED_VOLUMES"
    })
  end

  Resource("iamMFARule") do
    Type("AWS::Config::ConfigRule")
    DependsOn("iamMFAPerm")
    Property("ConfigRuleName", "ConSec-IAM-MFA-Rule")
    Property("Description", "Checks whether Users have an MFA Device configured.")
    Property("Scope", {
      "ComplianceResourceTypes" => [
        "AWS::IAM::User"
      ]
    })
    Property("Source", {
      "Owner"            => "CUSTOM_LAMBDA",
      "SourceDetails"    => [
        {
          "EventSource" => "aws.config",
          "MessageType" => "ConfigurationItemChangeNotification"
        }
      ],
      "SourceIdentifier" => FnGetAtt("iamMFAFunction", "Arn")
    })
  end

  Resource("iamUserInlinePolicyRule") do
    Type("AWS::Config::ConfigRule")
    DependsOn("iamUserInlinePolicyPerm")
    Property("ConfigRuleName", "ConSec-IAM-User-InlinePolicy-Rule")
    Property("Description", "Checks whether Users have an inline policy.")
    Property("Scope", {
      "ComplianceResourceTypes" => [
        "AWS::IAM::User"
      ]
    })
    Property("Source", {
      "Owner"            => "CUSTOM_LAMBDA",
      "SourceDetails"    => [
        {
          "EventSource" => "aws.config",
          "MessageType" => "ConfigurationItemChangeNotification"
        }
      ],
      "SourceIdentifier" => FnGetAtt("iamUserInlinePolicyFunction", "Arn")
    })
  end

  Resource("iamUserManagedPolicyRule") do
    Type("AWS::Config::ConfigRule")
    DependsOn("iamUserManagedPolicyPerm")
    Property("ConfigRuleName", "ConSec-IAM-User-ManagedPolicy-Rule")
    Property("Description", "Checks whether Users have a managed policy directly attached.")
    Property("Scope", {
      "ComplianceResourceTypes" => [
        "AWS::IAM::User"
      ]
    })
    Property("Source", {
      "Owner"            => "CUSTOM_LAMBDA",
      "SourceDetails"    => [
        {
          "EventSource" => "aws.config",
          "MessageType" => "ConfigurationItemChangeNotification"
        }
      ],
      "SourceIdentifier" => FnGetAtt("iamUserManagedPolicyFunction", "Arn")
    })
  end

  Resource("ec2SecGrpCidrIngressRule") do
    Type("AWS::Config::ConfigRule")
    DependsOn("ec2SecGrpCidrIngressPerm")
    Property("ConfigRuleName", "ConSec-EC2-SecGrp-Cidr-Ingress-Rule")
    Property("Description", "Checks whether a Security Group has an ingress rule with a CIDR range that disallows unrestricted traffic and applies to a single host.")
    Property("Scope", {
      "ComplianceResourceTypes" => [
        "AWS::EC2::SecurityGroup"
      ]
    })
    Property("Source", {
      "Owner"            => "CUSTOM_LAMBDA",
      "SourceDetails"    => [
        {
          "EventSource" => "aws.config",
          "MessageType" => "ConfigurationItemChangeNotification"
        }
      ],
      "SourceIdentifier" => FnGetAtt("ec2SecGrpCidrIngressFunction", "Arn")
    })
  end

  Resource("ec2SecGrpCidrEgressRule") do
    Type("AWS::Config::ConfigRule")
    DependsOn("ec2SecGrpCidrEgressPerm")
    Property("ConfigRuleName", "ConSec-EC2-SecGrp-Cidr-Egress-Rule")
    Property("Description", "Checks whether a Security Group has an egress rule with a CIDR range that disallows unrestricted traffic and applies to a single host.")
    Property("Scope", {
      "ComplianceResourceTypes" => [
        "AWS::EC2::SecurityGroup"
      ]
    })
    Property("Source", {
      "Owner"            => "CUSTOM_LAMBDA",
      "SourceDetails"    => [
        {
          "EventSource" => "aws.config",
          "MessageType" => "ConfigurationItemChangeNotification"
        }
      ],
      "SourceIdentifier" => FnGetAtt("ec2SecGrpCidrEgressFunction", "Arn")
    })
  end

  Resource("iamMFAPerm") do
    Type("AWS::Lambda::Permission")
    Property("FunctionName", FnGetAtt("iamMFAFunction", "Arn"))
    Property("Action", "lambda:InvokeFunction")
    Property("Principal", "config.amazonaws.com")
  end

  Resource("iamUserInlinePolicyPerm") do
    Type("AWS::Lambda::Permission")
    Property("FunctionName", FnGetAtt("iamUserInlinePolicyFunction", "Arn"))
    Property("Action", "lambda:InvokeFunction")
    Property("Principal", "config.amazonaws.com")
  end

  Resource("iamUserManagedPolicyPerm") do
    Type("AWS::Lambda::Permission")
    Property("FunctionName", FnGetAtt("iamUserManagedPolicyFunction", "Arn"))
    Property("Action", "lambda:InvokeFunction")
    Property("Principal", "config.amazonaws.com")
  end

  Resource("ec2SecGrpCidrIngressPerm") do
    Type("AWS::Lambda::Permission")
    Property("FunctionName", FnGetAtt("ec2SecGrpCidrIngressFunction", "Arn"))
    Property("Action", "lambda:InvokeFunction")
    Property("Principal", "config.amazonaws.com")
  end

  Resource("ec2SecGrpCidrEgressPerm") do
    Type("AWS::Lambda::Permission")
    Property("FunctionName", FnGetAtt("ec2SecGrpCidrEgressFunction", "Arn"))
    Property("Action", "lambda:InvokeFunction")
    Property("Principal", "config.amazonaws.com")
  end

  Resource("lambdaExecutionRole") do
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
              "lambda.amazonaws.com"
            ]
          }
        }
      ],
      "Version"   => "2012-10-17"
    })
    Property("Path", "/")
    Property("Policies", [
      {
        "PolicyDocument" => {
          "Statement" => [
            {
              "Action"   => [
                "iam:List*",
                "iam:Get*",
                "ec2:Describe*"
              ],
              "Effect"   => "Allow",
              "Resource" => "*"
            },
            {
              "Action"   => [
                "config:*"
              ],
              "Effect"   => "Allow",
              "Resource" => "*"
            },
            {
              "Action"   => [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
              ],
              "Effect"   => "Allow",
              "Resource" => "arn:aws:logs:*:*:*"
            }
          ],
          "Version"   => "2012-10-17"
        },
        "PolicyName"     => "root"
      }
    ])
  end

  Output("StackName") do
    Value(Ref("AWS::StackName"))
  end
end
