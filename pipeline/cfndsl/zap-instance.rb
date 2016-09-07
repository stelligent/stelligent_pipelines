CloudFormation do
  Description("Stelligent CloudFormation Template for launching OWASP Zed Attack Proxy (ZAP) on an EC2 instance ** This template creates one or more Amazon resources. You will be billed for the AWS resources used if you create a stack from this template.")
  AWSTemplateFormatVersion("2010-09-09")

  Parameter("Ec2Key") do
    Description("Ec2 key for ssh access")
    Type("String")
  end

  Parameter("pZapAmiId") do
    Description("AMI ID for ZAP server")
    Type("String")
    Default("ami-cdb588a7")
  end

  Parameter("SubnetId") do
    Description("VPC subnet id in which to place zap")
    Type("String")
  end

  Parameter("VPC") do
    Description("VPC ID in which to place Zap")
    Type("String")
  end

  Parameter("CfnInitRole") do
    Description("IAM Role for cfn-init")
    Type("String")
  end

  Parameter("InstanceProfile") do
    Description("Instance profile for ZAP instance")
    Type("String")
  end

  Parameter("SshCidr") do
    Description("Whitelisted network CIDR for inbound SSH")
    Type("String")
    Default("0.0.0.0/0")
  end

  Mapping("RegionConfig", {
    "us-east-1" => {
      "ami" => "ami-cdb588a7"
    }
  })

  Condition("NoEc2Key", FnEquals(Ref("Ec2Key"), ""))

  Resource("ZapSecurityGroup") do
    Type("AWS::EC2::SecurityGroup")
    Property("VpcId", Ref("VPC"))
    Property("GroupDescription", "Open SSH and ZAP")
    Property("SecurityGroupIngress", [
      {
        "CidrIp"     => Ref("SshCidr"),
        "FromPort"   => "22",
        "IpProtocol" => "tcp",
        "ToPort"     => "22"
      },
      {
        "CidrIp"     => Ref("SshCidr"),
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

  Resource("ZapInstance") do
    Type("AWS::EC2::Instance")
    CreationPolicy("ResourceSignal", {
      "Timeout" => "PT15M"
    })
        Metadata("AWS::CloudFormation::Init": {
      "packages" => {
        "python" => {
          "behave"                => [],
          "python-owasp-zap-v2.4" => []
        }
      }
    })
    Property("ImageId", Ref("pZapAmiId"))
    Property("InstanceType", "t2.micro")
    Property("IamInstanceProfile", Ref("InstanceProfile"))
    Property("KeyName", FnIf("NoEc2Key", Ref("AWS::NoValue"), Ref("Ec2Key")))
    Property("Tags", [
      {
        "Key"   => "Application",
        "Value" => Ref("AWS::StackId")
      },
      {
        "Key"   => "Name",
        "Value" => Ref("AWS::StackName")
      }
    ])
    Property("NetworkInterfaces", [
      {
        "AssociatePublicIpAddress" => "true",
        "DeleteOnTermination"      => "true",
        "DeviceIndex"              => "0",
        "GroupSet"                 => [
          Ref("ZapSecurityGroup")
        ],
        "SubnetId"                 => Ref("SubnetId")
      }
    ])
    Property("UserData", FnBase64(FnJoin("", [
      "#!/bin/bash -xe\n",
      "yum update -y aws-cfn-bootstrap\n",
      "yum -y upgrade\n",
      "\n",
      "service zap stop\n",
      "/opt/aws/bin/cfn-init -v",
      " --stack ",
      Ref("AWS::StackName"),
      " --resource ZapInstance ",
      " --role ",
      Ref("CfnInitRole"),
      " --region ",
      Ref("AWS::Region"),
      "\n",
      "pip install behave python-owasp-zap-v2.4\n",
      "/etc/init.d/zap start\n",
      "\n",
      "/opt/aws/bin/cfn-signal -e $? ",
      " --stack ",
      Ref("AWS::StackName"),
      " --resource ZapInstance ",
      " --region ",
      Ref("AWS::Region"),
      "\n"
    ])))
  end

  Output("StackName") do
    Value(Ref("AWS::StackName"))
  end

  Output("PublicDns") do
    Description("Public DNS of Zap instance")
    Value(FnGetAtt("ZapInstance", "PublicIp"))
  end

  Output("ZapURL") do
    Description("Zap URL")
    Value(FnJoin("", [
      "http://",
      FnGetAtt("ZapInstance", "PublicIp"),
      ":8080"
    ]))
  end

  Output("SecurityGroup") do
    Description("Zap Security Group")
    Value(FnGetAtt("ZapSecurityGroup", "GroupId"))
  end
end
