# frozen_string_literal: true
CloudFormation do
  Description('Store CFN Outputs to consume in downstream CFN stacks')
  AWSTemplateFormatVersion('2010-09-09')

  Parameter('UUID') do
    Description('Unique identifier to uniquely name Resources')
    Type('String')
    Default('EMPTY')
  end

  Parameter('MasterStackName') do
    Description('Name of the master.json CFN stack')
    Type('String')
    Default('EMPTY')
  end

  Parameter('DromedaryS3Bucket') do
    Description('Name of S3 bucket used to store Jenkins config')
    Type('String')
    Default('EMPTY')
  end

  Parameter('DemoResultsBucket') do
    Description('Name of the S3 bucket used to store test results')
    Type('String')
    Default('EMPTY')
  end

  Parameter('Branch') do
    Description('Name of Dromedary Github branch')
    Type('String')
    Default('EMPTY')
  end

  Parameter('KeyName') do
    Description('EC2 KeyPair')
    Type('String')
    Default('EMPTY')
  end

  Parameter('MyBuildProvider') do
    Description('Jenkins Build Provider Name')
    Type('String')
    Default('EMPTY')
  end

  Parameter('JobConfigsTarball') do
    Description('S3 key for DromedaryS3Bucket')
    Type('String')
    Default('EMPTY')
  end

  Parameter('Hostname') do
    Description('subdomain name')
    Type('String')
    Default('EMPTY')
  end

  Parameter('Domain') do
    Description('Route53 Hosted Zone name for prod IP (include trailing .)')
    Type('String')
    Default('oneclickdeployment.com.')
  end

  Parameter('ProdHostedZone') do
    Description('Route53 Hosted Zone (e.g. PRODHOST.HOSTED.ZONE)')
    Type('String')
    AllowedPattern('^.*?\\..*?\\..*$')
  end

  Parameter('VPCStackName') do
    Description('VPCStackName')
    Type('String')
    Default('EMPTY')
  end

  Parameter('IAMStackName') do
    Description('IAMStackName')
    Type('String')
    Default('EMPTY')
  end

  Parameter('DDBStackName') do
    Description('DDBStackName')
    Type('String')
    Default('EMPTY')
  end

  Parameter('ConfigStackName') do
    Description('ConfigStackName')
    Type('String')
    Default('EMPTY')
  end

  Parameter('LambdaConfigStackName') do
    Description('LambdaConfigStackName')
    Type('String')
    Default('EMPTY')
  end

  Parameter('ENIStackName') do
    Description('ENIStackName')
    Type('String')
    Default('EMPTY')
  end

  Parameter('DromedaryAppURL') do
    Description('The URL users use to launch the Dromedary application')
    Type('String')
    Default('EMPTY')
  end

  Parameter('ZapStackName') do
    Description('ZapStackName')
    Type('String')
    Default('EMPTY')
  end

  Resource('MyQueue') do
    Type('AWS::SQS::Queue')
    Property('QueueName', FnJoin('', [
                                   'PipelineStoreQueue-',
                                   Ref('UUID')
                                 ]))
  end

  Output('StackName') do
    Value(Ref('AWS::StackName'))
  end

  Output('UUID') do
    Value(Ref('UUID'))
  end

  Output('MasterStackName') do
    Description('Name of the Master CFN Stack')
    Value(Ref('MasterStackName'))
  end

  Output('DromedaryS3Bucket') do
    Description('Name of S3 bucket used to store Jenkins config')
    Value(Ref('DromedaryS3Bucket'))
  end

  Output('DemoResultsBucket') do
    Description('Name of the S3 bucket used to store test results')
    Value(Ref('DemoResultsBucket'))
  end

  Output('Branch') do
    Description('TBD')
    Value(Ref('Branch'))
  end

  Output('KeyName') do
    Description('TBD')
    Value(Ref('KeyName'))
  end

  Output('MyBuildProvider') do
    Description('TBD')
    Value(Ref('MyBuildProvider'))
  end

  Output('JobConfigsTarball') do
    Description('S3 key for DromedaryS3Bucket')
    Value(Ref('JobConfigsTarball'))
  end

  Output('Hostname') do
    Description('subdomain name')
    Value(Ref('Hostname'))
  end

  Output('Domain') do
    Description('Route53 Hosted Zone name for prod IP (include trailing .)')
    Value(Ref('Domain'))
  end

  Output('ProdHostedZone') do
    Description('Route53 Hosted Zone (e.g. PRODHOST.HOSTED.ZONE)')
    Value(Ref('ProdHostedZone'))
  end

  Output('VPCStackName') do
    Description('TBD')
    Value(Ref('VPCStackName'))
  end

  Output('IAMStackName') do
    Description('TBD')
    Value(Ref('IAMStackName'))
  end

  Output('DDBStackName') do
    Description('TBD')
    Value(Ref('DDBStackName'))
  end

  Output('ENIStackName') do
    Description('TBD')
    Value(Ref('ENIStackName'))
  end

  Output('ConfigStackName') do
    Description('TBD')
    Value(Ref('ConfigStackName'))
  end

  Output('LambdaConfigStackName') do
    Description('TBD')
    Value(Ref('LambdaConfigStackName'))
  end

  Output('DromedaryAppURL') do
    Description('The URL users use to launch the Dromedary application')
    Value(Ref('DromedaryAppURL'))
  end

  Output('ZapStackName') do
    Description('Zap Stack to query')
    Value(Ref('ZapStackName'))
  end
end
