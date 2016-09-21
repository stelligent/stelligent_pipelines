# frozen_string_literal: true
CloudFormation do
  Description('Dromedary demo - network infrastructure')
  AWSTemplateFormatVersion('2010-09-09')

  Resource('VPC') do
    Type('AWS::EC2::VPC')
    Property('CidrBlock', '10.0.0.0/16')
    Property('Tags', [
               {
                 'Key'   => 'Name',
                 'Value' => Ref('AWS::StackName')
               },
               {
                 'Key'   => 'Application',
                 'Value' => Ref('AWS::StackId')
               }
             ])
  end

  Resource('Subnet') do
    Type('AWS::EC2::Subnet')
    Property('VpcId', Ref('VPC'))
    Property('CidrBlock', '10.0.0.0/24')
    Property('Tags', [
               {
                 'Key'   => 'Name',
                 'Value' => Ref('AWS::StackName')
               },
               {
                 'Key'   => 'Application',
                 'Value' => Ref('AWS::StackId')
               }
             ])
  end

  Resource('InternetGateway') do
    Type('AWS::EC2::InternetGateway')
    Property('Tags', [
               {
                 'Key'   => 'Name',
                 'Value' => Ref('AWS::StackName')
               },
               {
                 'Key'   => 'Application',
                 'Value' => Ref('AWS::StackId')
               }
             ])
  end

  Resource('AttachGateway') do
    Type('AWS::EC2::VPCGatewayAttachment')
    Property('VpcId', Ref('VPC'))
    Property('InternetGatewayId', Ref('InternetGateway'))
  end

  Resource('RouteTable') do
    Type('AWS::EC2::RouteTable')
    Property('VpcId', Ref('VPC'))
    Property('Tags', [
               {
                 'Key'   => 'Name',
                 'Value' => Ref('AWS::StackName')
               },
               {
                 'Key'   => 'Application',
                 'Value' => Ref('AWS::StackId')
               }
             ])
  end

  Resource('Route') do
    Type('AWS::EC2::Route')
    DependsOn('AttachGateway')
    Property('RouteTableId', Ref('RouteTable'))
    Property('DestinationCidrBlock', '0.0.0.0/0')
    Property('GatewayId', Ref('InternetGateway'))
  end

  Resource('SubnetRouteTableAssociation') do
    Type('AWS::EC2::SubnetRouteTableAssociation')
    Property('SubnetId', Ref('Subnet'))
    Property('RouteTableId', Ref('RouteTable'))
  end

  Resource('NetworkAcl') do
    Type('AWS::EC2::NetworkAcl')
    Property('VpcId', Ref('VPC'))
    Property('Tags', [
               {
                 'Key'   => 'Name',
                 'Value' => Ref('AWS::StackName')
               },
               {
                 'Key'   => 'Application',
                 'Value' => Ref('AWS::StackId')
               }
             ])
  end

  Resource('InboundSSHNetworkAclEntry') do
    Type('AWS::EC2::NetworkAclEntry')
    Property('NetworkAclId', Ref('NetworkAcl'))
    Property('RuleNumber', '100')
    Property('Protocol', '6')
    Property('RuleAction', 'allow')
    Property('Egress', 'false')
    Property('CidrBlock', '0.0.0.0/0')
    Property('PortRange', 'From' => '22',
                          'To' => '22')
  end

  Resource('InboundHTTPNetworkAclEntry') do
    Type('AWS::EC2::NetworkAclEntry')
    Property('NetworkAclId', Ref('NetworkAcl'))
    Property('RuleNumber', '105')
    Property('Protocol', '6')
    Property('RuleAction', 'allow')
    Property('Egress', 'false')
    Property('CidrBlock', '0.0.0.0/0')
    Property('PortRange', 'From' => '80',
                          'To'   => '80')
  end

  Resource('InboundHTTPNetworkAclEntry2') do
    Type('AWS::EC2::NetworkAclEntry')
    Property('NetworkAclId', Ref('NetworkAcl'))
    Property('RuleNumber', '110')
    Property('Protocol', '6')
    Property('RuleAction', 'allow')
    Property('Egress', 'false')
    Property('CidrBlock', '0.0.0.0/0')
    Property('PortRange', 'From' => '8080',
                          'To'   => '8080')
  end

  Resource('InboundHTTPSNetworkAclEntry') do
    Type('AWS::EC2::NetworkAclEntry')
    Property('NetworkAclId', Ref('NetworkAcl'))
    Property('RuleNumber', '130')
    Property('Protocol', '6')
    Property('RuleAction', 'allow')
    Property('Egress', 'false')
    Property('CidrBlock', '0.0.0.0/0')
    Property('PortRange', 'From' => '443',
                          'To'   => '443')
  end

  Resource('InboundNtpResponseUdpPortNetworkAclEntry') do
    Type('AWS::EC2::NetworkAclEntry')
    Property('NetworkAclId', Ref('NetworkAcl'))
    Property('RuleNumber', '120')
    Property('Protocol', '17')
    Property('RuleAction', 'allow')
    Property('Egress', 'false')
    Property('CidrBlock', '0.0.0.0/0')
    Property('PortRange', 'From' => '123',
                          'To'   => '123')
  end

  Resource('InboundNtpResponseTcpPortNetworkAclEntry') do
    Type('AWS::EC2::NetworkAclEntry')
    Property('NetworkAclId', Ref('NetworkAcl'))
    Property('RuleNumber', '125')
    Property('Protocol', '6')
    Property('RuleAction', 'allow')
    Property('Egress', 'false')
    Property('CidrBlock', '0.0.0.0/0')
    Property('PortRange', 'From' => '123',
                          'To'   => '123')
  end

  Resource('InboundResponsePortsNetworkAclEntry') do
    Type('AWS::EC2::NetworkAclEntry')
    Property('NetworkAclId', Ref('NetworkAcl'))
    Property('RuleNumber', '900')
    Property('Protocol', '6')
    Property('RuleAction', 'allow')
    Property('Egress', 'false')
    Property('CidrBlock', '0.0.0.0/0')
    Property('PortRange', 'From' => '1024',
                          'To' => '65535')
  end

  Resource('OutBoundHTTPNetworkAclEntry') do
    Type('AWS::EC2::NetworkAclEntry')
    Property('NetworkAclId', Ref('NetworkAcl'))
    Property('RuleNumber', '100')
    Property('Protocol', '6')
    Property('RuleAction', 'allow')
    Property('Egress', 'true')
    Property('CidrBlock', '0.0.0.0/0')
    Property('PortRange', 'From' => '80',
                          'To'   => '80')
  end

  Resource('OutBoundHTTPNetworkAclEntry2') do
    Type('AWS::EC2::NetworkAclEntry')
    Property('NetworkAclId', Ref('NetworkAcl'))
    Property('RuleNumber', '105')
    Property('Protocol', '6')
    Property('RuleAction', 'allow')
    Property('Egress', 'true')
    Property('CidrBlock', '0.0.0.0/0')
    Property('PortRange', 'From' => '8080',
                          'To'   => '8080')
  end

  Resource('OutBoundHTTPSNetworkAclEntry') do
    Type('AWS::EC2::NetworkAclEntry')
    Property('NetworkAclId', Ref('NetworkAcl'))
    Property('RuleNumber', '130')
    Property('Protocol', '6')
    Property('RuleAction', 'allow')
    Property('Egress', 'true')
    Property('CidrBlock', '0.0.0.0/0')
    Property('PortRange', 'From' => '443',
                          'To'   => '443')
  end

  Resource('OutBoundNtpUdpNetworkAclEntry') do
    Type('AWS::EC2::NetworkAclEntry')
    Property('NetworkAclId', Ref('NetworkAcl'))
    Property('RuleNumber', '115')
    Property('Protocol', '17')
    Property('RuleAction', 'allow')
    Property('Egress', 'true')
    Property('CidrBlock', '0.0.0.0/0')
    Property('PortRange', 'From' => '123',
                          'To'   => '123')
  end

  Resource('OutBoundNtpTcpNetworkAclEntry') do
    Type('AWS::EC2::NetworkAclEntry')
    Property('NetworkAclId', Ref('NetworkAcl'))
    Property('RuleNumber', '120')
    Property('Protocol', '6')
    Property('RuleAction', 'allow')
    Property('Egress', 'true')
    Property('CidrBlock', '0.0.0.0/0')
    Property('PortRange', 'From' => '123',
                          'To'   => '123')
  end

  Resource('OutBoundResponsePortsNetworkAclEntry') do
    Type('AWS::EC2::NetworkAclEntry')
    Property('NetworkAclId', Ref('NetworkAcl'))
    Property('RuleNumber', '900')
    Property('Protocol', '6')
    Property('RuleAction', 'allow')
    Property('Egress', 'true')
    Property('CidrBlock', '0.0.0.0/0')
    Property('PortRange', 'From' => '1024',
                          'To'   => '65535')
  end

  Resource('SubnetNetworkAclAssociation') do
    Type('AWS::EC2::SubnetNetworkAclAssociation')
    Property('SubnetId', Ref('Subnet'))
    Property('NetworkAclId', Ref('NetworkAcl'))
  end

  Output('StackName') do
    Value(Ref('AWS::StackName'))
  end

  Output('SubnetId') do
    Description('Id of VPC Subnet')
    Value(Ref('Subnet'))
  end

  Output('VPC') do
    Description('VPC ID')
    Value(Ref('VPC'))
  end
end
