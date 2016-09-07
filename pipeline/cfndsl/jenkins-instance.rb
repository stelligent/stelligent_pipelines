CloudFormation do
  Description("Stelligent CloudFormation Template for launching Jenkins on an EC2 instance ** This template creates one or more Amazon resources. You will be billed for the AWS resources used if you create a stack from this template.")
  AWSTemplateFormatVersion("2010-09-09")

  Parameter("Ec2Key") do
    Description("Ec2 key for ssh access")
    Type("String")
    Default("")
  end

  Parameter("SubnetId") do
    Description("VPC subnet id in which to place jenkins")
    Type("String")
  end

  Parameter("VPC") do
    Description("VPC ID in which to place Jenkins")
    Type("String")
  end

  Parameter("CfnInitRole") do
    Description("IAM Role for cfn-init")
    Type("String")
  end

  Parameter("InstanceProfile") do
    Description("Instance profile for jenkins instance")
    Type("String")
  end

  Parameter("S3Bucket") do
    Description("Artifact Bucket")
    Type("String")
  end

  Parameter("JobConfigsTarball") do
    Description("Path to config tarball in S3Bucket")
    Type("String")
  end

  Parameter("SshCidr") do
    Description("Whitelisted network CIDR for inbound SSH")
    Type("String")
    Default("0.0.0.0/0")
  end

  Mapping("RegionConfig", {
    "us-east-1" => {
      "ami" => "ami-dcc2b3b6"
    }
  })

  Condition("NoEc2Key", FnEquals(Ref("Ec2Key"), ""))

  Resource("JenkinsSecurityGroup") do
    Type("AWS::EC2::SecurityGroup")
    Property("VpcId", Ref("VPC"))
    Property("GroupDescription", "No ingress by default")
    Property("SecurityGroupEgress", [
      {
        "CidrIp"     => "0.0.0.0/0",
        "FromPort"   => "0",
        "IpProtocol" => "tcp",
        "ToPort"     => "65535"
      }
    ])
  end

  Resource("JenkinsInstance") do
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
      "config"   => {
        "commands" => {
          "00-extract-configs"             => {
            "command" => FnJoin("", [
              "cd /var/lib/jenkins/jobs/;",
              "tar xzf /tmp/job-configs.tgz;",
              "chown -R jenkins:jenkins .;"
            ])
          },
          "01-set-publicip-jenkins-config" => {
            "command" => FnJoin("", [
              "PUBLIC_IP=$(curl http://169.254.169.254/latest/meta-data/public-ipv4);",
              "sed -e \"s/%PUBLICIP%/$PUBLIC_IP/g\" -i /var/lib/jenkins/jenkins.model.JenkinsLocationConfiguration.xml"
            ])
          },
          "10-install-node"                => {
            "command" => FnJoin("", [
              "yum remove -y nodejs npm\n",
              "\n",
              "cd /usr/local && tar --strip-components 1 -xzf /tmp/node-install.tar.gz\n",
              "if [ ! -e /usr/bin/node ]; then\n",
              "  ln -s /usr/local/bin/node /usr/bin/node\n",
              "fi\n",
              "if [ ! -e /usr/bin/npm ]; then\n",
              "  ln -s /usr/local/bin/npm /usr/bin/npm\n",
              "fi\n"
            ]),
            "test"    => "test \"$(/usr/local/bin/node --version 2>/dev/null)\" != 'v0.12.7'"
          },
          "15-install-node-modules"        => {
            "command" => "npm install -g gulp"
          },
          "20-install-jq"                  => {
            "command" => "yum install -y jq"
          }
        },
        "files"    => {
          "/tmp/job-configs.tgz"                                            => {
            "authentication" => "S3AccessCreds",
            "group"          => "root",
            "mode"           => "000644",
            "owner"          => "root",
            "source"         => FnJoin("", [
              "https://s3.amazonaws.com/",
              Ref("S3Bucket"),
              "/",
              Ref("JobConfigsTarball")
            ])
          },
          "/tmp/node-install.tar.gz"                                        => {
            "group"  => "root",
            "mode"   => "000644",
            "owner"  => "root",
            "source" => "https://nodejs.org/dist/v0.12.7/node-v0.12.7-linux-x64.tar.gz"
          },
          "/var/lib/jenkins/jenkins.model.JenkinsLocationConfiguration.xml" => {
            "content" => FnJoin("", [
              "<?xml version='1.0' encoding='UTF-8'?>",
              "<jenkins.model.JenkinsLocationConfiguration>",
              "<adminAddress>address not configured yet &lt;nobody@nowhere&gt;</adminAddress>",
              "<jenkinsUrl>http://%PUBLICIP%:8080/</jenkinsUrl>",
              "</jenkins.model.JenkinsLocationConfiguration>"
            ]),
            "group"   => "jenkins",
            "mode"    => "000644",
            "owner"   => "jenkins"
          }
        }
      },
      "packages" => {
        "python" => {
          "behave"                => [],
          "python-owasp-zap-v2.4" => []
        }
      }
    })
    Property("ImageId", FnFindInMap("RegionConfig", Ref("AWS::Region"), "ami"))
    Property("InstanceType", "m4.large")
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
          Ref("JenkinsSecurityGroup")
        ],
        "SubnetId"                 => Ref("SubnetId")
      }
    ])
    Property("UserData", FnBase64(FnJoin("", [
      "#!/bin/bash -xe\n",
      "yum update -y aws-cfn-bootstrap\n",
      "yum -y upgrade\n",
      "\n",
      "service jenkins stop\n",
      "/opt/aws/bin/cfn-init -v",
      " --stack ",
      Ref("AWS::StackName"),
      " --resource JenkinsInstance ",
      " --role ",
      Ref("CfnInitRole"),
      " --region ",
      Ref("AWS::Region"),
      "\n",
      "\n",
      "service jenkins start\n",
      "node -v \n",
      "npm -v\n",
      "pip install behave python-owasp-zap-v2.4 boto3\n",
      "\n",
      "/opt/aws/bin/cfn-signal -e $? ",
      " --stack ",
      Ref("AWS::StackName"),
      " --resource JenkinsInstance ",
      " --region ",
      Ref("AWS::Region"),
      "\n"
    ])))
  end

  Output("StackName") do
    Value(Ref("AWS::StackName"))
  end

  Output("PublicDns") do
    Description("Public DNS of Jenkins instance")
    Value(FnGetAtt("JenkinsInstance", "PublicIp"))
  end

  Output("JenkinsURL") do
    Description("Jenkins URL")
    Value(FnJoin("", [
      "http://",
      FnGetAtt("JenkinsInstance", "PublicIp"),
      ":8080/"
    ]))
  end

  Output("SecurityGroup") do
    Description("Jenkins Security Group")
    Value(FnGetAtt("JenkinsSecurityGroup", "GroupId"))
  end
end
