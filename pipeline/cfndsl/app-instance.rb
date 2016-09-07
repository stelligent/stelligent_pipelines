CloudFormation do
  Description("Dromedary demo - application instance")
  AWSTemplateFormatVersion("2010-09-09")

  Parameter("Ec2Key") do
    Description("Ec2 key for ssh access")
    Type("String")
    Default("")
  end

  Parameter("SubnetId") do
    Description("VPC subnet id in which to place instance")
    Type("String")
  end

  Parameter("VPC") do
    Description("VPC id in which to place instance")
    Type("String")
  end

  Parameter("CfnInitRole") do
    Description("IAM Role for cfn-init")
    Type("String")
  end

  Parameter("InstanceProfile") do
    Description("Instance profile for app instance")
    Type("String")
  end

  Parameter("S3Bucket") do
    Description("Artifact Bucket")
    Type("String")
  end

  Parameter("ArtifactPath") do
    Description("Path to tarball in Artifact Bucket")
    Type("String")
    Default("")
  end

  Parameter("CodeDeployTag") do
    Description("Resource Tags for Deployment Group (non-zero enables CodeDeploy agent)")
    Type("String")
    Default("1")
  end

  Parameter("DynamoDbTable") do
    Description("DynamoDb table name for persistent storage")
    Type("String")
    MaxLength(32)
    MinLength(1)
  end

  Mapping("RegionConfig", {
    "us-east-1" => {
      "ami" => "ami-2d652448"
    }
  })

  Condition("NoEc2Key", FnEquals(Ref("Ec2Key"), ""))

  Condition("InstallCodeDeploy", FnNot([
    FnEquals(Ref("CodeDeployTag"), "")
  ]))

  Resource("InstanceSecurityGroup") do
    Type("AWS::EC2::SecurityGroup")
    Property("VpcId", Ref("VPC"))
    Property("GroupDescription", "Enable SSH access via port 22")
    Property("SecurityGroupIngress", [
      {
        "CidrIp"     => "152.3.4.5/32",
        "FromPort"   => "22",
        "IpProtocol" => "tcp",
        "ToPort"     => "22"
      },
      {
        "CidrIp"     => "0.0.0.0/0",
        "FromPort"   => "80",
        "IpProtocol" => "tcp",
        "ToPort"     => "80"
      },
      {
        "CidrIp"     => "0.0.0.0/0",
        "FromPort"   => "443",
        "IpProtocol" => "tcp",
        "ToPort"     => "443"
      },
      {
        "CidrIp"     => "0.0.0.0/0",
        "FromPort"   => "8080",
        "IpProtocol" => "tcp",
        "ToPort"     => "8080"
      }
    ])
    Property("SecurityGroupEgress", [
      {
        "CidrIp"     => "0.0.0.0/0",
        "FromPort"   => "0",
        "IpProtocol" => "tcp",
        "ToPort"     => "65535"
      }
    ])
  end

  Resource("WebServerInstance") do
    Type("AWS::EC2::Instance")
    CreationPolicy("ResourceSignal", {
      "Timeout" => "PT15M"
    })
    Metadata("AWS::CloudFormation::Authentication": {
      "S3AccessCreds" => {
        "buckets"  => [
          Ref("S3Bucket")
        ],
        "roleName" => Ref("CfnInitRole"),
        "type"     => "S3"
      }
    })
    Metadata("AWS::CloudFormation::Init": {
      "base"       => {
        "commands" => {
          "10-extract-dromedary" => {
            "command" => FnJoin("", [
              "mkdir -p -m755 /userdata\n",
              "cd /userdata\n",
              "tar xzf /tmp/dromedary.tgz\n"
            ])
          },
          "20-run-chef"          => {
            "command" => FnJoin("", [
              "cat > /userdata/solo.rb <<SOLORB\n",
              "cookbook_path ['/userdata']\n",
              "SOLORB\n",
              "\n",
              "chef-solo --config /userdata/solo.rb --log_level auto --force-formatter --json-attributes /userdata/dromedary/attributes.json\n",
              "node -v \n",
              "npm -v\n"
            ]),
            "cwd"     => "/userdata",
            "env"     => {
              "DROMEDARY_DDB_TABLE_NAME" => Ref("DynamoDbTable"),
              "HOME"                     => "/root"
            }
          }
        },
        "files"    => {
          "/tmp/dromedary.tgz" => {
            "authentication" => "S3AccessCreds",
            "group"          => "root",
            "mode"           => "000644",
            "owner"          => "root",
            "source"         => FnJoin("", [
              "https://s3.amazonaws.com/",
              Ref("S3Bucket"),
              "/",
              Ref("ArtifactPath")
            ])
          }
        }
      },
      "chef"       => {
        "commands" => {
          "10-install-chef" => {
            "command" => "rpm -ivh /tmp/chefdk.rpm"
          }
        },
        "files"    => {
          "/tmp/chefdk.rpm" => {
            "group"  => "root",
            "mode"   => "000644",
            "owner"  => "root",
            "source" => "https://opscode-omnibus-packages.s3.amazonaws.com/el/6/x86_64/chefdk-0.7.0-1.el6.x86_64.rpm"
          }
        }
      },
      "configSets" => {
        "base"      => [
          "base"
        ],
        "chef"      => [
          "chef"
        ],
        "default"   => [
          {
            "ConfigSet" => "base"
          }
        ],
        "noprereqs" => [
          "noprereqs"
        ]
      },
      "noprereqs"  => {
        "commands" => {
          "10-extract-dromedary" => {
            "command" => FnJoin("", [
              "mkdir -p -m755 /userdata\n",
              "cd /userdata\n",
              "tar xzf /tmp/dromedary.tgz\n"
            ])
          },
          "20-run-chef"          => {
            "command" => FnJoin("", [
              "cat > /userdata/solo.rb <<SOLORB\n",
              "cookbook_path ['/userdata']\n",
              "SOLORB\n",
              "\n",
              "chef-solo --config /userdata/solo.rb --log_level auto --force-formatter --json-attributes /userdata/dromedary/attributes-noprereqs.json\n",
              "node -v \n",
              "npm -v\n"
            ]),
            "cwd"     => "/userdata",
            "env"     => {
              "DROMEDARY_DDB_TABLE_NAME" => Ref("DynamoDbTable"),
              "HOME"                     => "/root"
            }
          }
        },
        "files"    => {
          "/tmp/dromedary.tgz" => {
            "authentication" => "S3AccessCreds",
            "group"          => "root",
            "mode"           => "000644",
            "owner"          => "root",
            "source"         => FnJoin("", [
              "https://s3.amazonaws.com/",
              Ref("S3Bucket"),
              "/",
              Ref("ArtifactPath")
            ])
          }
        }
      }
    })
    Property("ImageId", FnFindInMap("RegionConfig", Ref("AWS::Region"), "ami"))
    Property("InstanceType", "m4.large")
    Property("IamInstanceProfile", Ref("InstanceProfile"))
    Property("KeyName", FnIf("NoEc2Key", Ref("AWS::NoValue"), Ref("Ec2Key")))
    Property("Tags", FnIf("InstallCodeDeploy", [
      {
        "Key"   => "Application",
        "Value" => Ref("AWS::StackId")
      },
      {
        "Key"   => "Name",
        "Value" => Ref("AWS::StackName")
      },
      {
        "Key"   => "environment",
        "Value" => Ref("CodeDeployTag")
      }
    ],
    [
      {
        "Key"   => "Application",
        "Value" => Ref("AWS::StackId")
      },
      {
        "Key"   => "Name",
        "Value" => Ref("AWS::StackName")
      }
    ]))
    Property("NetworkInterfaces", [
      {
        "AssociatePublicIpAddress" => "true",
        "DeleteOnTermination"      => "true",
        "DeviceIndex"              => "0",
        "GroupSet"                 => [
          Ref("InstanceSecurityGroup")
        ],
        "SubnetId"                 => Ref("SubnetId")
      }
    ])
    Property("UserData", FnBase64(FnJoin("", [
      "#!/bin/bash -xe\n",
      "yum update -y aws-cfn-bootstrap\n",
      "\n",
      "# Helper functions\n",
      "function error_exit\n",
      "{\n",
      "  /opt/aws/bin/cfn-signal -e 1 -r \"$1\"",
      " --stack ",
      Ref("AWS::StackName"),
      " --resource WebServerInstance ",
      " --region ",
      Ref("AWS::Region"),
      "\n",
      "  exit 1\n",
      "}\n",
      "function cfn_init\n",
      "{\n",
      "  /opt/aws/bin/cfn-init -v -s ",
      Ref("AWS::StackId"),
      " -r WebServerInstance --region ",
      Ref("AWS::Region"),
      " --role ",
      Ref("CfnInitRole"),
      " \"$@\"\n",
      "}\n",
      "function cfn_signal_ok\n",
      "{\n",
      "  /opt/aws/bin/cfn-signal -e 0 ",
      " --stack ",
      Ref("AWS::StackName"),
      " --resource WebServerInstance ",
      " --region ",
      Ref("AWS::Region"),
      " || true\n",
      "}\n",
      "\n",
      "if ! which chef-solo > /dev/null 2>&2; then\n",
      "  cfn_init -c chef || error_exit 'Failed to run cfn-init chef'\n",
      "fi\n",
      "\n",
      "if [ -e /.dromedary-prereqs-installed ]; then\n",
      "  cfn_init -c noprereqs || error_exit 'Failed to run cfn-init noprereqs'\n",
      "else\n",
      "  yum -y upgrade\n",
      "  cfn_init || error_exit 'Failed to run cfn-init'\n",
      "fi\n",
      "cfn_signal_ok\n",
      "\n"
    ])))
  end

  Output("PublicDns") do
    Description("Public DNS of Dromedary App instance")
    Value(FnGetAtt("WebServerInstance", "PublicIp"))
  end

  Output("InstanceId") do
    Description("Dromedary App instance id")
    Value(Ref("WebServerInstance"))
  end

  Output("InstanceSecurityGroup") do
    Description("Security group id of app instance")
    Value(Ref("InstanceSecurityGroup"))
  end
end
