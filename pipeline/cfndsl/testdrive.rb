# frozen_string_literal: true
CloudFormation do
  Description('Dromedary demo - AWS Test Drive deployment')
  AWSTemplateFormatVersion('2010-09-09')

  Parameter('DromedaryRepo') do
    Description('The Github https address to the public dromedary repository.')
    Type('String')
    Default('https://github.com/stelligent/dromedary.git')
  end

  Parameter('Branch') do
    Description('The Github branch the public dromedary repository.')
    Type('String')
    Default('master')
  end

  Parameter('ProdHostedZone') do
    Description('Route53 Hosted Zone (e.g. PRODHOST.HOSTED.ZONE)')
    Type('String')
    AllowedPattern('^.*?\\..*?\\..*$')
  end

  Parameter('AliveDuration') do
    Description('Duration to keep demo deployment active. (e.g. 4h, 3h, 30m, etc)')
    Type('String')
    Default('4h')
    AllowedPattern('[0-9]+(m|h)')
  end

  Parameter('GitHubToken') do
    Description('Secret. OAuthToken with access to Repo. The default is invalid and used for example purposes. Go to https://github.com/settings/tokens')
    Type('String')
    Default('4a189a34546435225614563ebd44a1531a4657af')
    NoEcho(true)
  end

  Parameter('GitHubUser') do
    Description('GitHub UserName. This username must have access to the GitHubToken.')
    Type('String')
    Default('stelligent')
  end

  Parameter('Ec2SshKeyName') do
    Description('The ec2 key name to use for ssh access to the bootstrapping instance.')
    Type('AWS::EC2::KeyPair::KeyName')
  end

  Mapping('RegionConfig', 'us-east-1' => {
            'ami' => 'ami-e3106686'
          })

  Resource('BootstrapVPC') do
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

  Resource('BootstrapSubnet') do
    Type('AWS::EC2::Subnet')
    Property('VpcId', Ref('BootstrapVPC'))
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

  Resource('BootstrapRouteTable') do
    Type('AWS::EC2::RouteTable')
    Property('VpcId', Ref('BootstrapVPC'))
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

  Resource('BootstrapRoute') do
    Type('AWS::EC2::Route')
    Property('RouteTableId', Ref('BootstrapRouteTable'))
    Property('DestinationCidrBlock', '0.0.0.0/0')
    Property('GatewayId', Ref('InternetGateway'))
  end

  Resource('PublicSubnetRouteTableAssociation') do
    Type('AWS::EC2::SubnetRouteTableAssociation')
    Property('SubnetId', Ref('BootstrapSubnet'))
    Property('RouteTableId', Ref('BootstrapRouteTable'))
  end

  Resource('BootstrapInstanceRole') do
    Type('AWS::IAM::Role')
    Property('AssumeRolePolicyDocument', 'Statement' => [
               {
                 'Action' => [
                   'sts:AssumeRole'
                 ],
                 'Effect'    => 'Allow',
                 'Principal' => {
                   'Service' => [
                     'ec2.amazonaws.com'
                   ]
                 }
               }
             ])
    Property('Path', '/')
    Property('Policies', [
               {
                 'PolicyDocument' => {
                   'Statement' => [
                     {
                       'Action'   => '*',
                       'Effect'   => 'Allow',
                       'Resource' => '*'
                     }
                   ]
                 },
                 'PolicyName' => 'AllowAll'
               }
             ])
  end

  Resource('BootstrapSecurityGroup') do
    Type('AWS::EC2::SecurityGroup')
    Property('VpcId', Ref('BootstrapVPC'))
    Property('GroupDescription', 'Open SSH port')
    Property('SecurityGroupIngress', [
               {
                 'CidrIp'     => '0.0.0.0/0',
                 'FromPort'   => '22',
                 'IpProtocol' => 'tcp',
                 'ToPort'     => '22'
               }
             ])
    Property('SecurityGroupEgress', [
               {
                 'CidrIp'     => external_parameters.get_param(:default_egress_ip),
                 'FromPort'   => external_parameters.get_param(:default_egress_from_port),
                 'IpProtocol' => 'tcp',
                 'ToPort'     => external_parameters.get_param(:default_egress_to_port)
               }
             ])
  end

  Resource('BootstrapInstanceProfile') do
    Type('AWS::IAM::InstanceProfile')
    Property('Path', '/')
    Property('Roles', [
               Ref('BootstrapInstanceRole')
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
    Property('VpcId', Ref('BootstrapVPC'))
    Property('InternetGatewayId', Ref('InternetGateway'))
  end

  Resource('BootstrapInstance') do
    Type('AWS::EC2::Instance')
    CreationPolicy('ResourceSignal', 'Count' => 1,
                                     'Timeout' => 'PT5M')
    Metadata("AWS::CloudFormation::Init": {
               'configSets' => {
                 'validation' => [
                   'validate_prodhost'
                 ]
               },
               'validate_prodhost' => {
                 'commands' => {
                   '01_validate_prodhost' => {
                     'command' => '/etc/validation',
                     'cwd'     => '/etc'
                   }
                 },
                 'files' => {
                   '/etc/validation' => {
                     'content' => FnJoin('', [
                                           "#!/bin/bash -xe\n",
                                           'aws route53 list-hosted-zones-by-name',
                                           ' | grep $(echo "',
                                           Ref('ProdHostedZone'),
                                           "\" | cut -d '.' --fields=2,3)\n",
                                           "exit $?\n"
                                         ]),
                     'group'   => 'root',
                     'mode'    => '000500',
                     'owner'   => 'root'
                   }
                 }
               }
             })
    Property('ImageId', FnFindInMap('RegionConfig', Ref('AWS::Region'), 'ami'))
    Property('InstanceType', 't2.micro')
    Property('IamInstanceProfile', Ref('BootstrapInstanceProfile'))
    Property('KeyName', Ref('Ec2SshKeyName'))
    Property('NetworkInterfaces', [
               {
                 'AssociatePublicIpAddress' => 'True',
                 'DeleteOnTermination'      => 'True',
                 'DeviceIndex'              => '0',
                 'GroupSet'                 => [
                   Ref('BootstrapSecurityGroup')
                 ],
                 'SubnetId' => Ref('BootstrapSubnet')
               }
             ])
    Property('Tags', [
               {
                 'Key'   => 'Application',
                 'Value' => Ref('AWS::StackId')
               },
               {
                 'Key'   => 'Name',
                 'Value' => Ref('AWS::StackName')
               }
             ])
    Property('UserData', FnBase64(FnJoin('', [
                                           "#!/bin/bash -x\n",
                                           '/opt/aws/bin/cfn-init --stack ',
                                           Ref('AWS::StackName'),
                                           ' --resource BootstrapInstance ',
                                           '--configsets validation',
                                           "\n",
                                           '/opt/aws/bin/cfn-signal --resource BootstrapInstance --exit-code $? --stack ',
                                           Ref('AWS::StackName'),
                                           ' --reason "Invalid Route53 hosted zone provided."',
                                           "\n",
                                           "yum install -y git\n",
                                           "gem install cucumber aws-sdk rspec rspec-expectations\n",
                                           'git clone -b ',
                                           Ref('Branch'),
                                           ' ',
                                           Ref('DromedaryRepo'),
                                           " /opt/dromedary\n",
                                           'export AWS_DEFAULT_REGION=',
                                           Ref('AWS::Region'),
                                           "\n",
                                           "cd /opt/dromedary\n",
                                           './bin/bootstrap-all.sh ',
                                           Ref('ProdHostedZone'),
                                           ' ',
                                           Ref('GitHubToken'),
                                           ' ',
                                           Ref('GitHubUser'),
                                           ' ',
                                           Ref('Branch'),
                                           "\n",
                                           "cd /opt/dromedary/test-infra/bootstrap\n",
                                           'ACCOUNT_ID=',
                                           Ref('AWS::AccountId'),
                                           "\n",
                                           '/usr/local/bin/cucumber',
                                           ' ACCTID=',
                                           '$ACCOUNT_ID',
                                           ' PROD=',
                                           '$(echo "',
                                           Ref('ProdHostedZone'),
                                           "\" | cut -d '.' -f1)",
                                           ' AWS_REGION=',
                                           Ref('AWS::Region'),
                                           ' ENVFILE=/opt/dromedary/environment.sh',
                                           " --tags @build --format html --out bootstrap-test.html\n",
                                           "echo 'Not run yet.' >> teardown-test.html\n",
                                           "aws s3 cp bootstrap-test.html s3://dromedary-$ACCOUNT_ID/tests/bootstrap/ --acl public-read\n",
                                           "aws s3 cp teardown-test.html s3://dromedary-$ACCOUNT_ID/tests/bootstrap/ --acl public-read\n",
                                           'sleep ',
                                           Ref('AliveDuration'),
                                           "\n",
                                           "cd /opt/dromedary\n",
                                           "yes | ./bin/delete-all.sh\n",
                                           "if [ $? -eq 0 ]; then\n",
                                           "cd /opt/dromedary/test-infra/bootstrap\n",
                                           '/usr/local/bin/cucumber',
                                           ' PROD=',
                                           '$(echo "',
                                           Ref('ProdHostedZone'),
                                           "\" | cut -d '.' -f1)",
                                           ' AWS_REGION=',
                                           Ref('AWS::Region'),
                                           ' ENVFILE=/opt/dromedary/environment.sh',
                                           " --tags @teardown --format html --out teardown-test.html\n",
                                           "aws s3 cp teardown-test.html s3://dromedary-$ACCOUNT_ID/tests/bootstrap/ --acl public-read\n",
                                           'aws cloudformation delete-stack --stack-name ',
                                           Ref('AWS::StackName'),
                                           "\n",
                                           "fi\n"
                                         ])))
  end

  Output('BootstrapTestResult') do
    Description('The infrastructure test results / logs for the bootstrapping action.')
    Value(FnJoin('', [
                   'https://s3.amazonaws.com/dromedary-',
                   Ref('AWS::AccountId'),
                   '/tests/bootstrap/bootstrap-test.html'
                 ]))
  end

  Output('TeardownTestResult') do
    Description('The infrastructure test results / logs for the automated bootstrap teardown action.')
    Value(FnJoin('', [
                   'https://s3.amazonaws.com/dromedary-',
                   Ref('AWS::AccountId'),
                   '/tests/bootstrap/teardown-test.html'
                 ]))
  end
end
