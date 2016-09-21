# frozen_string_literal: true
CloudFormation do
  Description('Setup Config Service')
  AWSTemplateFormatVersion('2010-09-09')

  Resource('ConfigBucket') do
    Type('AWS::S3::Bucket')
    DeletionPolicy('Retain')
    Property('AccessControl', 'BucketOwnerFullControl')
  end

  Resource('ConfigTopic') do
    Type('AWS::SNS::Topic')
    Property('DisplayName', 'config-topic')
    Property('TopicName', 'config-topic')
  end

  Resource('ConfigRole') do
    Type('AWS::IAM::Role')
    Property('AssumeRolePolicyDocument', 'Statement' => [
               {
                 'Action' => [
                   'sts:AssumeRole'
                 ],
                 'Effect'    => 'Allow',
                 'Principal' => {
                   'Service' => [
                     'config.amazonaws.com'
                   ]
                 }
               }
             ],
                                         'Version' => '2012-10-17')
    Property('Path', '/')
    Property('Policies', [
               {
                 'PolicyDocument' => {
                   'Statement' => [
                     {
                       'Action'   => 'sns:Publish',
                       'Effect'   => 'Allow',
                       'Resource' => Ref('ConfigTopic')
                     },
                     {
                       'Action' => [
                         's3:PutObject'
                       ],
                       'Condition' => {
                         'StringLike' => {
                           's3:x-amz-acl' => 'bucket-owner-full-control'
                         }
                       },
                       'Effect'    => 'Allow',
                       'Resource'  => [
                         FnJoin('', [
                                  'arn:aws:s3:::',
                                  Ref('ConfigBucket'),
                                  '/AWSLogs/',
                                  Ref('AWS::AccountId'),
                                  '/*'
                                ])
                       ]
                     },
                     {
                       'Action' => [
                         's3:GetBucketAcl'
                       ],
                       'Effect'   => 'Allow',
                       'Resource' => FnJoin('', [
                                              'arn:aws:s3:::',
                                              Ref('ConfigBucket')
                                            ])
                     },
                     {
                       'Action' => [
                         'appstream:Get*',
                         'autoscaling:Describe*',
                         'cloudformation:DescribeStacks',
                         'cloudformation:DescribeStackEvents',
                         'cloudformation:DescribeStackResource',
                         'cloudformation:DescribeStackResources',
                         'cloudformation:GetTemplate',
                         'cloudformation:List*',
                         'cloudfront:Get*',
                         'cloudfront:List*',
                         'cloudtrail:DescribeTrails',
                         'cloudtrail:GetTrailStatus',
                         'cloudwatch:Describe*',
                         'cloudwatch:Get*',
                         'cloudwatch:List*',
                         'config:Put*',
                         'directconnect:Describe*',
                         'dynamodb:GetItem',
                         'dynamodb:BatchGetItem',
                         'dynamodb:Query',
                         'dynamodb:Scan',
                         'dynamodb:DescribeTable',
                         'dynamodb:ListTables',
                         'ec2:Describe*',
                         'elasticache:Describe*',
                         'elasticbeanstalk:Check*',
                         'elasticbeanstalk:Describe*',
                         'elasticbeanstalk:List*',
                         'elasticbeanstalk:RequestEnvironmentInfo',
                         'elasticbeanstalk:RetrieveEnvironmentInfo',
                         'elasticloadbalancing:Describe*',
                         'elastictranscoder:Read*',
                         'elastictranscoder:List*',
                         'iam:List*',
                         'iam:Get*',
                         'kinesis:Describe*',
                         'kinesis:Get*',
                         'kinesis:List*',
                         'opsworks:Describe*',
                         'opsworks:Get*',
                         'route53:Get*',
                         'route53:List*',
                         'redshift:Describe*',
                         'redshift:ViewQueriesInConsole',
                         'rds:Describe*',
                         'rds:ListTagsForResource',
                         's3:Get*',
                         's3:List*',
                         'sdb:GetAttributes',
                         'sdb:List*',
                         'sdb:Select*',
                         'ses:Get*',
                         'ses:List*',
                         'sns:Get*',
                         'sns:List*',
                         'sqs:GetQueueAttributes',
                         'sqs:ListQueues',
                         'sqs:ReceiveMessage',
                         'storagegateway:List*',
                         'storagegateway:Describe*',
                         'tag:Get*',
                         'trustedadvisor:Describe*'
                       ],
                       'Effect'   => 'Allow',
                       'Resource' => '*'
                     }
                   ]
                 },
                 'PolicyName' => 'root'
               }
             ])
  end

  Resource('ConfigRecorder') do
    Type('AWS::Config::ConfigurationRecorder')
    Property('Name', 'default')
    Property('RecordingGroup', 'ResourceTypes' => [
               'AWS::EC2::Instance',
               'AWS::EC2::InternetGateway',
               'AWS::EC2::NetworkAcl',
               'AWS::EC2::NetworkInterface',
               'AWS::EC2::RouteTable',
               'AWS::EC2::SecurityGroup',
               'AWS::EC2::Subnet',
               'AWS::EC2::Volume',
               'AWS::EC2::VPC',
               'AWS::IAM::Policy',
               'AWS::IAM::Role',
               'AWS::IAM::User'
             ])
    Property('RoleARN', FnGetAtt('ConfigRole', 'Arn'))
  end

  Resource('DeliveryChannel') do
    Type('AWS::Config::DeliveryChannel')
    Property('ConfigSnapshotDeliveryProperties', 'DeliveryFrequency' => 'Twelve_Hours')
    Property('S3BucketName', Ref('ConfigBucket'))
    Property('SnsTopicARN', Ref('ConfigTopic'))
  end

  Output('StackName') do
    Value(Ref('AWS::StackName'))
  end
end
