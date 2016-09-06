CloudFormation do
  Description("Dromedary demo - create ENI and EIP and route 53 handling")
  AWSTemplateFormatVersion("2010-09-09")

  Parameter("Hostname") do
    Description("DNS Hostname for prod IP (but not domainname)")
    Type("String")
    Default("")
  end

  Parameter("Domain") do
    Description("Route53 Hosted Zone name for prod IP (include trailing .)")
    Type("String")
    Default("")
  end

  Parameter("SubnetId") do
    Description("TODO: Modify this later. VPC subnet id in which to place ENI")
    Type("String")
    Default("")
  end

  Parameter("SecurityGroupId") do
    Description("Security Group id with which to associate app ENI")
    Type("String")
    Default("")
  end

  Condition("NoSecurityGroup", FnEquals(Ref("SecurityGroupId"), ""))

  Condition("Route53Update", FnAnd([
    FnNot([
      FnEquals(Ref("Hostname"), "")
    ]),
    FnNot([
      FnEquals(Ref("Domain"), "")
    ])
  ]))

  Resource("EIP") do
    Type("AWS::EC2::EIP")
    Property("Domain", "vpc")
  end

  Resource("ProdDNSRecord") do
    Type("AWS::Route53::RecordSet")
    Condition("Route53Update")
    Property("HostedZoneName", Ref("Domain"))
    Property("Comment", "DNS name for Dromedary prod.")
    Property("Name", FnJoin("", [
      Ref("Hostname"),
      ".",
      Ref("Domain")
    ]))
    Property("Type", "A")
    Property("TTL", "120")
    Property("ResourceRecords", [
      Ref("EIP")
    ])
  end

  Resource("ENI") do
    Type("AWS::EC2::NetworkInterface")
    Property("Description", "Dromedary Prod ENI")
    Property("SubnetId", Ref("SubnetId"))
    Property("GroupSet", FnIf("NoSecurityGroup", Ref("AWS::NoValue"), [
      Ref("SecurityGroupId")
    ]))
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
  end

  Resource("EipAssocation") do
    Type("AWS::EC2::EIPAssociation")
    Property("AllocationId", FnGetAtt("EIP", "AllocationId"))
    Property("NetworkInterfaceId", Ref("ENI"))
  end

  Output("StackName") do
    Value(Ref("AWS::StackName"))
  end

  Output("PublicIp") do
    Description("Public IP Address of ENI")
    Value(Ref("EIP"))
  end

  Output("EniId") do
    Description("Elastic Network Interface Id")
    Value(Ref("ENI"))
  end
end
