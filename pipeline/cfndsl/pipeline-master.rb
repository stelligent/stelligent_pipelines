# frozen_string_literal: true
CloudFormation do
  Description('Master dromedary stack that calls nested stacks')
  AWSTemplateFormatVersion('2010-09-09')

  Parameter('KeyName') do
    Description('Name of an existing EC2 KeyPair to enable SSH access to the instances')
    Type('AWS::EC2::KeyPair::KeyName')
    ConstraintDescription('must be the name of an existing EC2 KeyPair.')
  end

  Parameter('Repo') do
    Description('The name of the dromedary repository, not the URL')
    Type('String')
    Default('dromedary')
  end

  Parameter('GitHubToken') do
    Description('Secret. OAuthToken with access to Repo. The default is invalid and used for example purposes. Go to https://github.com/settings/tokens')
    Type('String')
    NoEcho(true)
  end

  Parameter('GitHubUser') do
    Description('GitHub UserName. This username must have access to the GitHubToken.')
    Type('String')
    Default('stelligent')
  end

  Parameter('BaseTemplateURL') do
    Description('S3 Base URL of all the CloudFormation templated used in Dromedary (without the file names)')
    Type('String')
    Default('https://s3.amazonaws.com/stelligent-training-public/master/')
  end

  Parameter('VPCCFNTemplateFile') do
    Description('Just the name of the CloudFormation template. Used with BaseTemplateURL.')
    Type('String')
    Default('vpc.json')
  end

  Parameter('CodePipelineCFNTemplateFile') do
    Description('Just the name of the CloudFormation template. Used with BaseTemplateURL.')
    Type('String')
    Default('codepipeline-cfn.json')
  end

  Parameter('CodePipelineActionsCFNTemplateFile') do
    Description('Just the name of the CloudFormation template. Used with BaseTemplateURL.')
    Type('String')
    Default('codepipeline-custom-actions.json')
  end

  Parameter('ENICFNTemplateFile') do
    Description('Just the name of the CloudFormation template. Used with BaseTemplateURL.')
    Type('String')
    Default('app-eni.json')
  end

  Parameter('ZapCFNTemplateFile') do
    Description('Just the name of the CloudFormation template. Used with BaseTemplateURL.')
    Type('String')
    Default('zap-instance.json')
  end

  Parameter('pZapAmiId') do
    Description('AMI ID for ZAP server')
    Type('String')
    Default('ami-cdb588a7')
  end

  Parameter('JenkinsCFNTemplateFile') do
    Description('Just the name of the CloudFormation template. Used with BaseTemplateURL.')
    Type('String')
    Default('jenkins-instance.json')
  end

  Parameter('PipelineStoreCFNTemplateFile') do
    Description('Just the name of the CloudFormation template. Used with BaseTemplateURL.')
    Type('String')
    Default('pipeline-store.json')
  end

  Parameter('IAMCFNTemplateFile') do
    Description('Just the name of the CloudFormation template. Used with BaseTemplateURL.')
    Type('String')
    Default('iam.json')
  end

  Parameter('DDBCFNTemplateFile') do
    Description('Just the name of the CloudFormation template. Used with BaseTemplateURL.')
    Type('String')
    Default('dynamodb.json')
  end

  Parameter('ConfigCFNTemplateFile') do
    Description('Just the name of the CloudFormation template. Used with BaseTemplateURL.')
    Type('String')
    Default('config.json')
  end

  Parameter('LambdaConfigCFNTemplateFile') do
    Description('Just the name of the CloudFormation template. Used with BaseTemplateURL.')
    Type('String')
    Default('lambda-config.json')
  end

  Parameter('pCloudFrontCFNTemplateFile') do
    Description('Just the name of the CloudFormation template. Used with BaseTemplateURL.')
    Type('String')
    Default('cloudfront-cfn.json')
  end

  Parameter('DDBTableName') do
    Description('Unique name for the Dromedary Dynamo DB table')
    Type('String')
  end

  Parameter('pPipelinesRepo') do
    Description('The Github https address to the public stelligent_pipelines repository.')
    Type('String')
    Default('https://github.com/stelligent/stelligent_pipelines.git')
  end

  Parameter('pPipelinesBranch') do
    Description('The Github branch the public stelligent_pipelines repository.')
    Type('String')
    Default('master')
  end

  Parameter('Branch') do
    Description('The Github branch the public dromedary repository.')
    Type('String')
    Default('master')
  end

  Parameter('Domain') do
    Description('Route53 Hosted Zone name for prod IP (include trailing .)')
    Type('String')
    Default('oneclickdeployment.com.')
  end

  Parameter('ProdHostedZone') do
    Description('Route53 Hosted Zone (e.g. .HOSTEDZONE or .oneclickdeployment.com)')
    Type('String')
  end

  Parameter('InstanceType') do
    Description('WebServer EC2 instance type')
    Type('String')
    Default('m3.medium')
    AllowedValues([
                    't1.micro',
                    't2.nano',
                    't2.micro',
                    't2.small',
                    't2.medium',
                    't2.large',
                    'm1.small',
                    'm1.medium',
                    'm1.large',
                    'm1.xlarge',
                    'm2.xlarge',
                    'm2.2xlarge',
                    'm2.4xlarge',
                    'm3.medium',
                    'm3.large',
                    'm3.xlarge',
                    'm3.2xlarge',
                    'm4.large',
                    'm4.xlarge',
                    'm4.2xlarge',
                    'm4.4xlarge',
                    'm4.10xlarge',
                    'c1.medium',
                    'c1.xlarge',
                    'c3.large',
                    'c3.xlarge',
                    'c3.2xlarge',
                    'c3.4xlarge',
                    'c3.8xlarge',
                    'c4.large',
                    'c4.xlarge',
                    'c4.2xlarge',
                    'c4.4xlarge',
                    'c4.8xlarge',
                    'g2.2xlarge',
                    'g2.8xlarge',
                    'r3.large',
                    'r3.xlarge',
                    'r3.2xlarge',
                    'r3.4xlarge',
                    'r3.8xlarge',
                    'i2.xlarge',
                    'i2.2xlarge',
                    'i2.4xlarge',
                    'i2.8xlarge',
                    'd2.xlarge',
                    'd2.2xlarge',
                    'd2.4xlarge',
                    'd2.8xlarge',
                    'hi1.4xlarge',
                    'hs1.8xlarge',
                    'cr1.8xlarge',
                    'cc2.8xlarge',
                    'cg1.4xlarge'
                  ])
    ConstraintDescription('must be a valid EC2 instance type.')
  end

  Parameter('SSHLocation') do
    Description('The IP address range that can be used to SSH to the EC2 instances')
    Type('String')
    Default('0.0.0.0/0')
    AllowedPattern('(\\d{1,3})\\.(\\d{1,3})\\.(\\d{1,3})\\.(\\d{1,3})/(\\d{1,2})')
    MaxLength(18)
    MinLength(9)
    ConstraintDescription('must be a valid IP CIDR range of the form x.x.x.x/x.')
  end

  Parameter('pEnableCloudFrontAndWaf') do
    Type('String')
    Default('false')
  end

  Parameter('pEnableConfig') do
    Type('String')
    Default('true')
  end

  Parameter('pDemoResultsBucket') do
    Description('S3 Bucket to store pipeline test results in. Should already exist.')
    Type('String')
    Default('demo.stelligent-continuous-security.com')
  end

  Mapping('Region2Examples', 'ap-northeast-1' => {
            'Examples' => 'https://s3-ap-northeast-1.amazonaws.com/cloudformation-examples-ap-northeast-1'
          },
                             'ap-northeast-2' => {
                               'Examples' => 'https://s3-ap-northeast-2.amazonaws.com/cloudformation-examples-ap-northeast-2'
                             },
                             'ap-southeast-1' => {
                               'Examples' => 'https://s3-ap-southeast-1.amazonaws.com/cloudformation-examples-ap-southeast-1'
                             },
                             'ap-southeast-2' => {
                               'Examples' => 'https://s3-ap-southeast-2.amazonaws.com/cloudformation-examples-ap-southeast-2'
                             },
                             'cn-north-1' => {
                               'Examples' => 'https://s3.cn-north-1.amazonaws.com.cn/cloudformation-examples-cn-north-1'
                             },
                             'eu-central-1' => {
                               'Examples' => 'https://s3-eu-central-1.amazonaws.com/cloudformation-examples-eu-central-1'
                             },
                             'eu-west-1' => {
                               'Examples' => 'https://s3-eu-west-1.amazonaws.com/cloudformation-examples-eu-west-1'
                             },
                             'sa-east-1' => {
                               'Examples' => 'https://s3-sa-east-1.amazonaws.com/cloudformation-examples-sa-east-1'
                             },
                             'us-east-1' => {
                               'Examples' => 'https://s3.amazonaws.com/cloudformation-examples-us-east-1'
                             },
                             'us-west-1' => {
                               'Examples' => 'https://s3-us-west-1.amazonaws.com/cloudformation-examples-us-west-1'
                             },
                             'us-west-2' => {
                               'Examples' => 'https://s3-us-west-2.amazonaws.com/cloudformation-examples-us-west-2'
                             })

  Mapping('AWSInstanceType2Arch', 'c1.medium' => {
            'Arch' => 'PV64'
          },
                                  'c1.xlarge' => {
                                    'Arch' => 'PV64'
                                  },
                                  'c3.2xlarge' => {
                                    'Arch' => 'HVM64'
                                  },
                                  'c3.4xlarge' => {
                                    'Arch' => 'HVM64'
                                  },
                                  'c3.8xlarge' => {
                                    'Arch' => 'HVM64'
                                  },
                                  'c3.large' => {
                                    'Arch' => 'HVM64'
                                  },
                                  'c3.xlarge' => {
                                    'Arch' => 'HVM64'
                                  },
                                  'c4.2xlarge' => {
                                    'Arch' => 'HVM64'
                                  },
                                  'c4.4xlarge' => {
                                    'Arch' => 'HVM64'
                                  },
                                  'c4.8xlarge' => {
                                    'Arch' => 'HVM64'
                                  },
                                  'c4.large' => {
                                    'Arch' => 'HVM64'
                                  },
                                  'c4.xlarge' => {
                                    'Arch' => 'HVM64'
                                  },
                                  'cc2.8xlarge' => {
                                    'Arch' => 'HVM64'
                                  },
                                  'cr1.8xlarge' => {
                                    'Arch' => 'HVM64'
                                  },
                                  'd2.2xlarge' => {
                                    'Arch' => 'HVM64'
                                  },
                                  'd2.4xlarge' => {
                                    'Arch' => 'HVM64'
                                  },
                                  'd2.8xlarge' => {
                                    'Arch' => 'HVM64'
                                  },
                                  'd2.xlarge' => {
                                    'Arch' => 'HVM64'
                                  },
                                  'g2.2xlarge' => {
                                    'Arch' => 'HVMG2'
                                  },
                                  'g2.8xlarge' => {
                                    'Arch' => 'HVMG2'
                                  },
                                  'hi1.4xlarge' => {
                                    'Arch' => 'HVM64'
                                  },
                                  'hs1.8xlarge' => {
                                    'Arch' => 'HVM64'
                                  },
                                  'i2.2xlarge' => {
                                    'Arch' => 'HVM64'
                                  },
                                  'i2.4xlarge' => {
                                    'Arch' => 'HVM64'
                                  },
                                  'i2.8xlarge' => {
                                    'Arch' => 'HVM64'
                                  },
                                  'i2.xlarge' => {
                                    'Arch' => 'HVM64'
                                  },
                                  'm1.large' => {
                                    'Arch' => 'PV64'
                                  },
                                  'm1.medium' => {
                                    'Arch' => 'PV64'
                                  },
                                  'm1.small' => {
                                    'Arch' => 'PV64'
                                  },
                                  'm1.xlarge' => {
                                    'Arch' => 'PV64'
                                  },
                                  'm2.2xlarge' => {
                                    'Arch' => 'PV64'
                                  },
                                  'm2.4xlarge' => {
                                    'Arch' => 'PV64'
                                  },
                                  'm2.xlarge' => {
                                    'Arch' => 'PV64'
                                  },
                                  'm3.2xlarge' => {
                                    'Arch' => 'HVM64'
                                  },
                                  'm3.large' => {
                                    'Arch' => 'HVM64'
                                  },
                                  'm3.medium' => {
                                    'Arch' => 'HVM64'
                                  },
                                  'm3.xlarge' => {
                                    'Arch' => 'HVM64'
                                  },
                                  'm4.10xlarge' => {
                                    'Arch' => 'HVM64'
                                  },
                                  'm4.2xlarge' => {
                                    'Arch' => 'HVM64'
                                  },
                                  'm4.4xlarge' => {
                                    'Arch' => 'HVM64'
                                  },
                                  'm4.large' => {
                                    'Arch' => 'HVM64'
                                  },
                                  'm4.xlarge' => {
                                    'Arch' => 'HVM64'
                                  },
                                  'r3.2xlarge' => {
                                    'Arch' => 'HVM64'
                                  },
                                  'r3.4xlarge' => {
                                    'Arch' => 'HVM64'
                                  },
                                  'r3.8xlarge' => {
                                    'Arch' => 'HVM64'
                                  },
                                  'r3.large' => {
                                    'Arch' => 'HVM64'
                                  },
                                  'r3.xlarge' => {
                                    'Arch' => 'HVM64'
                                  },
                                  't1.micro' => {
                                    'Arch' => 'PV64'
                                  },
                                  't2.large' => {
                                    'Arch' => 'HVM64'
                                  },
                                  't2.medium' => {
                                    'Arch' => 'HVM64'
                                  },
                                  't2.micro' => {
                                    'Arch' => 'HVM64'
                                  },
                                  't2.nano' => {
                                    'Arch' => 'HVM64'
                                  },
                                  't2.small' => {
                                    'Arch' => 'HVM64'
                                  })

  Mapping('AWSInstanceType2NATArch', 'c1.medium' => {
            'Arch' => 'NATPV64'
          },
                                     'c1.xlarge' => {
                                       'Arch' => 'NATPV64'
                                     },
                                     'c3.2xlarge' => {
                                       'Arch' => 'NATHVM64'
                                     },
                                     'c3.4xlarge' => {
                                       'Arch' => 'NATHVM64'
                                     },
                                     'c3.8xlarge' => {
                                       'Arch' => 'NATHVM64'
                                     },
                                     'c3.large' => {
                                       'Arch' => 'NATHVM64'
                                     },
                                     'c3.xlarge' => {
                                       'Arch' => 'NATHVM64'
                                     },
                                     'c4.2xlarge' => {
                                       'Arch' => 'NATHVM64'
                                     },
                                     'c4.4xlarge' => {
                                       'Arch' => 'NATHVM64'
                                     },
                                     'c4.8xlarge' => {
                                       'Arch' => 'NATHVM64'
                                     },
                                     'c4.large' => {
                                       'Arch' => 'NATHVM64'
                                     },
                                     'c4.xlarge' => {
                                       'Arch' => 'NATHVM64'
                                     },
                                     'cc2.8xlarge' => {
                                       'Arch' => 'NATHVM64'
                                     },
                                     'cr1.8xlarge' => {
                                       'Arch' => 'NATHVM64'
                                     },
                                     'd2.2xlarge' => {
                                       'Arch' => 'NATHVM64'
                                     },
                                     'd2.4xlarge' => {
                                       'Arch' => 'NATHVM64'
                                     },
                                     'd2.8xlarge' => {
                                       'Arch' => 'NATHVM64'
                                     },
                                     'd2.xlarge' => {
                                       'Arch' => 'NATHVM64'
                                     },
                                     'g2.2xlarge' => {
                                       'Arch' => 'NATHVMG2'
                                     },
                                     'g2.8xlarge' => {
                                       'Arch' => 'NATHVMG2'
                                     },
                                     'hi1.4xlarge' => {
                                       'Arch' => 'NATHVM64'
                                     },
                                     'hs1.8xlarge' => {
                                       'Arch' => 'NATHVM64'
                                     },
                                     'i2.2xlarge' => {
                                       'Arch' => 'NATHVM64'
                                     },
                                     'i2.4xlarge' => {
                                       'Arch' => 'NATHVM64'
                                     },
                                     'i2.8xlarge' => {
                                       'Arch' => 'NATHVM64'
                                     },
                                     'i2.xlarge' => {
                                       'Arch' => 'NATHVM64'
                                     },
                                     'm1.large' => {
                                       'Arch' => 'NATPV64'
                                     },
                                     'm1.medium' => {
                                       'Arch' => 'NATPV64'
                                     },
                                     'm1.small' => {
                                       'Arch' => 'NATPV64'
                                     },
                                     'm1.xlarge' => {
                                       'Arch' => 'NATPV64'
                                     },
                                     'm2.2xlarge' => {
                                       'Arch' => 'NATPV64'
                                     },
                                     'm2.4xlarge' => {
                                       'Arch' => 'NATPV64'
                                     },
                                     'm2.xlarge' => {
                                       'Arch' => 'NATPV64'
                                     },
                                     'm3.2xlarge' => {
                                       'Arch' => 'NATHVM64'
                                     },
                                     'm3.large' => {
                                       'Arch' => 'NATHVM64'
                                     },
                                     'm3.medium' => {
                                       'Arch' => 'NATHVM64'
                                     },
                                     'm3.xlarge' => {
                                       'Arch' => 'NATHVM64'
                                     },
                                     'm4.10xlarge' => {
                                       'Arch' => 'NATHVM64'
                                     },
                                     'm4.2xlarge' => {
                                       'Arch' => 'NATHVM64'
                                     },
                                     'm4.4xlarge' => {
                                       'Arch' => 'NATHVM64'
                                     },
                                     'm4.large' => {
                                       'Arch' => 'NATHVM64'
                                     },
                                     'm4.xlarge' => {
                                       'Arch' => 'NATHVM64'
                                     },
                                     'r3.2xlarge' => {
                                       'Arch' => 'NATHVM64'
                                     },
                                     'r3.4xlarge' => {
                                       'Arch' => 'NATHVM64'
                                     },
                                     'r3.8xlarge' => {
                                       'Arch' => 'NATHVM64'
                                     },
                                     'r3.large' => {
                                       'Arch' => 'NATHVM64'
                                     },
                                     'r3.xlarge' => {
                                       'Arch' => 'NATHVM64'
                                     },
                                     't1.micro' => {
                                       'Arch' => 'NATPV64'
                                     },
                                     't2.large' => {
                                       'Arch' => 'NATHVM64'
                                     },
                                     't2.medium' => {
                                       'Arch' => 'NATHVM64'
                                     },
                                     't2.micro' => {
                                       'Arch' => 'NATHVM64'
                                     },
                                     't2.nano' => {
                                       'Arch' => 'NATHVM64'
                                     },
                                     't2.small' => {
                                       'Arch' => 'NATHVM64'
                                     })

  Mapping('AWSRegionArch2AMI', 'ap-northeast-1' => {
            'HVM64' => 'ami-383c1956',
            'HVMG2' => 'ami-08e5c166',
            'PV64'  => 'ami-393c1957'
          },
                               'ap-northeast-2' => {
                                 'HVM64' => 'ami-249b554a',
                                 'HVMG2' => 'NOT_SUPPORTED',
                                 'PV64'  => 'NOT_SUPPORTED'
                               },
                               'ap-southeast-1' => {
                                 'HVM64' => 'ami-c9b572aa',
                                 'HVMG2' => 'ami-5a15d239',
                                 'PV64'  => 'ami-34bd7a57'
                               },
                               'ap-southeast-2' => {
                                 'HVM64' => 'ami-48d38c2b',
                                 'HVMG2' => 'ami-0c1a446f',
                                 'PV64'  => 'ami-ced887ad'
                               },
                               'cn-north-1' => {
                                 'HVM64' => 'ami-43a36a2e',
                                 'HVMG2' => 'NOT_SUPPORTED',
                                 'PV64'  => 'ami-18ac6575'
                               },
                               'eu-central-1' => {
                                 'HVM64' => 'ami-bc5b48d0',
                                 'HVMG2' => 'ami-ba1a09d6',
                                 'PV64'  => 'ami-794a5915'
                               },
                               'eu-west-1' => {
                                 'HVM64' => 'ami-bff32ccc',
                                 'HVMG2' => 'ami-83fd23f0',
                                 'PV64'  => 'ami-95e33ce6'
                               },
                               'sa-east-1' => {
                                 'HVM64' => 'ami-6817af04',
                                 'HVMG2' => 'NOT_SUPPORTED',
                                 'PV64'  => 'ami-7d15ad11'
                               },
                               'us-east-1' => {
                                 'HVM64' => 'ami-60b6c60a',
                                 'HVMG2' => 'ami-e998ea83',
                                 'PV64'  => 'ami-5fb8c835'
                               },
                               'us-west-1' => {
                                 'HVM64' => 'ami-d5ea86b5',
                                 'HVMG2' => 'ami-943956f4',
                                 'PV64'  => 'ami-56ea8636'
                               },
                               'us-west-2' => {
                                 'HVM64' => 'ami-f0091d91',
                                 'HVMG2' => 'ami-315f4850',
                                 'PV64'  => 'ami-d93622b8'
                               })

  Mapping('Region2Principal',             'ap-northeast-1' => {
            'EC2Principal' => 'ec2.amazonaws.com',
            'OpsWorksPrincipal' => 'opsworks.amazonaws.com'
          },
                                          'ap-northeast-2' => {
                                            'EC2Principal'      => 'ec2.amazonaws.com',
                                            'OpsWorksPrincipal' => 'opsworks.amazonaws.com'
                                          },
                                          'ap-southeast-1' => {
                                            'EC2Principal'      => 'ec2.amazonaws.com',
                                            'OpsWorksPrincipal' => 'opsworks.amazonaws.com'
                                          },
                                          'ap-southeast-2' => {
                                            'EC2Principal'      => 'ec2.amazonaws.com',
                                            'OpsWorksPrincipal' => 'opsworks.amazonaws.com'
                                          },
                                          'cn-north-1' => {
                                            'EC2Principal'      => 'ec2.amazonaws.com.cn',
                                            'OpsWorksPrincipal' => 'opsworks.amazonaws.com.cn'
                                          },
                                          'eu-central-1' => {
                                            'EC2Principal'      => 'ec2.amazonaws.com',
                                            'OpsWorksPrincipal' => 'opsworks.amazonaws.com'
                                          },
                                          'eu-west-1' => {
                                            'EC2Principal'      => 'ec2.amazonaws.com',
                                            'OpsWorksPrincipal' => 'opsworks.amazonaws.com'
                                          },
                                          'sa-east-1' => {
                                            'EC2Principal'      => 'ec2.amazonaws.com',
                                            'OpsWorksPrincipal' => 'opsworks.amazonaws.com'
                                          },
                                          'us-east-1' => {
                                            'EC2Principal'      => 'ec2.amazonaws.com',
                                            'OpsWorksPrincipal' => 'opsworks.amazonaws.com'
                                          },
                                          'us-west-1' => {
                                            'EC2Principal'      => 'ec2.amazonaws.com',
                                            'OpsWorksPrincipal' => 'opsworks.amazonaws.com'
                                          },
                                          'us-west-2' => {
                                            'EC2Principal'      => 'ec2.amazonaws.com',
                                            'OpsWorksPrincipal' => 'opsworks.amazonaws.com'
                                          })

  Mapping('Region2ARNPrefix',             'ap-northeast-1' => {
            'ARNPrefix' => 'arn:aws:'
          },
                                          'ap-northeast-2' => {
                                            'ARNPrefix' => 'arn:aws:'
                                          },
                                          'ap-southeast-1' => {
                                            'ARNPrefix' => 'arn:aws:'
                                          },
                                          'ap-southeast-2' => {
                                            'ARNPrefix' => 'arn:aws:'
                                          },
                                          'cn-north-1' => {
                                            'ARNPrefix' => 'arn:aws-cn:'
                                          },
                                          'eu-central-1' => {
                                            'ARNPrefix' => 'arn:aws:'
                                          },
                                          'eu-west-1' => {
                                            'ARNPrefix' => 'arn:aws:'
                                          },
                                          'sa-east-1' => {
                                            'ARNPrefix' => 'arn:aws:'
                                          },
                                          'us-east-1' => {
                                            'ARNPrefix' => 'arn:aws:'
                                          },
                                          'us-west-1' => {
                                            'ARNPrefix' => 'arn:aws:'
                                          },
                                          'us-west-2' => {
                                            'ARNPrefix' => 'arn:aws:'
                                          })

  Condition('cEnableCloudFrontAndWaf', FnEquals(Ref('pEnableCloudFrontAndWaf'), 'true'))

  Condition('cEnableConfig', FnEquals(Ref('pEnableConfig'), 'true'))

  Resource('LogRole') do
    Type('AWS::IAM::Role')
    DependsOn([
                'DynamoDBStack'
              ])
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

  Resource('LogRoleInstanceProfile') do
    Type('AWS::IAM::InstanceProfile')
    DependsOn([
                'DynamoDBStack'
              ])
    Property('Path', '/')
    Property('Roles', [
               Ref('LogRole')
             ])
  end

  Resource('CloudFormationLogs') do
    Type('AWS::Logs::LogGroup')
    DependsOn([
                'DynamoDBStack'
              ])
    Property('RetentionInDays', 7)
  end

  Resource('WebServerInstance') do
    Type('AWS::EC2::Instance')
    CreationPolicy('ResourceSignal', 'Count' => 1,
                                     'Timeout' => 'PT10M')
    Metadata("AWS::CloudFormation::Init": {
               'configSets' => {
                 'install_all' => %w(
                   install_cfn
                   install_app
                   install_logs
                 )
               },
               'install_app' => {
                 'files' => {
                   '/var/www/html/index.html' => {
                     'content' => FnJoin("
                     ", [
                       '<img src="',
                       FnFindInMap('Region2Examples', Ref('AWS::Region'), 'Examples'),
                       '/cloudformation_graphic.png" alt="AWS CloudFormation Logo"/>',
                       '<h1>Congratulations, you have successfully launched the AWS CloudFormation sample.</h1>'
                     ]),
                     'group'   => 'root',
                     'mode'    => '000644',
                     'owner'   => 'root'
                   }
                 },
                 'packages' => {
                   'yum' => {
                     'httpd' => []
                   }
                 },
                 'services' => {
                   'sysvinit' => {
                     'httpd' => {
                       'enabled'       => 'true',
                       'ensureRunning' => 'true'
                     }
                   }
                 }
               },
               'install_cfn' => {
                 'files' => {
                   '/etc/cfn/cfn-hup.conf' => {
                     'content' => FnJoin('', [
                                           "[main]\n",
                                           'stack=',
                                           Ref('AWS::StackId'),
                                           "\n",
                                           'region=',
                                           Ref('AWS::Region'),
                                           "\n"
                                         ]),
                     'group'   => 'root',
                     'mode'    => '000400',
                     'owner'   => 'root'
                   },
                   '/etc/cfn/hooks.d/cfn-auto-reloader.conf' => {
                     'content' => FnJoin('', [
                                           "[cfn-auto-reloader-hook]\n",
                                           "triggers=post.update\n",
                                           "path=Resources.WebServerInstance.Metadata.AWS::CloudFormation::Init\n",
                                           'action=/opt/aws/bin/cfn-init -v ',
                                           '         --stack ',
                                           Ref('AWS::StackName'),
                                           '         --resource WebServerInstance ',
                                           '         --configsets install_all ',
                                           '         --region ',
                                           Ref('AWS::Region'),
                                           "\n",
                                           "runas=root\n"
                                         ])
                   }
                 },
                 'services' => {
                   'sysvinit' => {
                     'cfn-hup' => {
                       'enabled'       => 'true',
                       'ensureRunning' => 'true',
                       'files'         => [
                         '/etc/cfn/cfn-hup.conf',
                         '/etc/cfn/hooks.d/cfn-auto-reloader.conf'
                       ]
                     }
                   }
                 }
               },
               'install_logs' => {
                 'commands' => {
                   '01_create_state_directory' => {
                     'command' => 'mkdir -p /var/awslogs/state'
                   },
                   '02_create_my_tmp_directory' => {
                     'command' => 'mkdir -p /tmp/pmd'
                   }
                 },
                 'files' => {
                   '/etc/awslogs/awscli.conf' => {
                     'content' => FnJoin('', [
                                           "[plugins]\n",
                                           "cwlogs = cwlogs\n",
                                           "[default]\n",
                                           'region = ',
                                           Ref('AWS::Region'),
                                           "\n"
                                         ]),
                     'group'   => 'root',
                     'mode'    => '000444',
                     'owner'   => 'root'
                   },
                   '/etc/awslogs/awslogs.conf' => {
                     'content' => FnJoin('', [
                                           "[general]\n",
                                           "state_file= /var/awslogs/state/agent-state\n",
                                           "[/var/log/cloud-init.log]\n",
                                           "file = /var/log/cloud-init.log\n",
                                           'log_group_name = ',
                                           Ref('CloudFormationLogs'),
                                           "\n",
                                           "log_stream_name = {instance_id}/cloud-init.log\n",
                                           "datetime_format = \n",
                                           "[/var/log/cloud-init-output.log]\n",
                                           "file = /var/log/cloud-init-output.log\n",
                                           'log_group_name = ',
                                           Ref('CloudFormationLogs'),
                                           "\n",
                                           "log_stream_name = {instance_id}/cloud-init-output.log\n",
                                           "datetime_format = \n",
                                           "[/var/log/cfn-init.log]\n",
                                           "file = /var/log/cfn-init.log\n",
                                           'log_group_name = ',
                                           Ref('CloudFormationLogs'),
                                           "\n",
                                           "log_stream_name = {instance_id}/cfn-init.log\n",
                                           "datetime_format = \n",
                                           "[/var/log/cfn-hup.log]\n",
                                           "file = /var/log/cfn-hup.log\n",
                                           'log_group_name = ',
                                           Ref('CloudFormationLogs'),
                                           "\n",
                                           "log_stream_name = {instance_id}/cfn-hup.log\n",
                                           "datetime_format = \n",
                                           "[/var/log/cfn-wire.log]\n",
                                           "file = /var/log/cfn-wire.log\n",
                                           'log_group_name = ',
                                           Ref('CloudFormationLogs'),
                                           "\n",
                                           "log_stream_name = {instance_id}/cfn-wire.log\n",
                                           "datetime_format = \n",
                                           "[/var/log/httpd]\n",
                                           "file = /var/log/httpd/*\n",
                                           'log_group_name = ',
                                           Ref('CloudFormationLogs'),
                                           "\n",
                                           "log_stream_name = {instance_id}/httpd\n",
                                           "datetime_format = %d/%b/%Y:%H:%M:%S\n"
                                         ]),
                     'group'   => 'root',
                     'mode'    => '000444',
                     'owner'   => 'root'
                   }
                 },
                 'packages' => {
                   'yum' => {
                     'awslogs' => []
                   }
                 },
                 'services' => {
                   'sysvinit' => {
                     'awslogs' => {
                       'enabled'       => 'true',
                       'ensureRunning' => 'true',
                       'files'         => [
                         '/etc/awslogs/awslogs.conf'
                       ]
                     }
                   }
                 }
               }
             })
    DependsOn(%w(
                DynamoDBStack
                PipelineStoreStack
                VPCStack
              ))
    Property('NetworkInterfaces', [
               {
                 'AssociatePublicIpAddress' => true,
                 'DeleteOnTermination'      => true,
                 'DeviceIndex'              => '0',
                 'GroupSet'                 => [
                   Ref('InstanceSecurityGroup')
                 ],
                 'SubnetId' => FnGetAtt('VPCStack', 'Outputs.SubnetId')
               }
             ])
    Property('KeyName', Ref('KeyName'))
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
    Property('InstanceType', Ref('InstanceType'))
    Property('IamInstanceProfile', Ref('LogRoleInstanceProfile'))
    Property('ImageId', FnFindInMap('AWSRegionArch2AMI', Ref('AWS::Region'), FnFindInMap('AWSInstanceType2Arch', Ref('InstanceType'), 'Arch')))
    Property('UserData', FnBase64(FnJoin('', [
                                           "#!/bin/bash -xe\n",
                                           "yum update -y aws-cfn-bootstrap\n",
                                           '/opt/aws/bin/cfn-init -v ',
                                           '         --stack ',
                                           Ref('AWS::StackName'),
                                           '         --resource WebServerInstance ',
                                           '         --configsets install_all ',
                                           '         --region ',
                                           Ref('AWS::Region'),
                                           "\n",
                                           "yum install -y git\n",
                                           'git clone -b ',
                                           Ref('pPipelinesBranch'),
                                           ' ',
                                           Ref('pPipelinesRepo'),
                                           " /opt/pipelines\n",
                                           'export AWS_DEFAULT_REGION=',
                                           Ref('AWS::Region'),
                                           "\n",
                                           "cd /opt/pipelines\n",
                                           './bin/configure-jenkins.sh ',
                                           FnGetAtt('PipelineStoreStack', 'Outputs.StackName'),
                                           "\n",
                                           '/opt/aws/bin/cfn-signal -e $? ',
                                           '         --stack ',
                                           Ref('AWS::StackName'),
                                           '         --resource WebServerInstance ',
                                           '         --region ',
                                           Ref('AWS::Region'),
                                           "\n"
                                         ])))
  end

  Resource('InstanceSecurityGroup') do
    Type('AWS::EC2::SecurityGroup')
    Property('VpcId', FnGetAtt('VPCStack', 'Outputs.VPC'))
    Property('GroupDescription', 'Enable SSH access and HTTP access on the inbound port')
    Property('SecurityGroupIngress', [
               {
                 'CidrIp'     => Ref('SSHLocation'),
                 'FromPort'   => '22',
                 'IpProtocol' => 'tcp',
                 'ToPort'     => '22'
               },
               {
                 'CidrIp'     => '0.0.0.0/0',
                 'FromPort'   => '80',
                 'IpProtocol' => 'tcp',
                 'ToPort'     => '80'
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

  Resource('DynamoDBStack') do
    Type('AWS::CloudFormation::Stack')
    Property('TemplateURL', FnJoin('', [
                                     Ref('BaseTemplateURL'),
                                     Ref('DDBCFNTemplateFile')
                                   ]))
    Property('TimeoutInMinutes', '60')
    Property('Parameters', 'DDBTableName' => Ref('DDBTableName'))
  end

  Resource('VPCStack') do
    Type('AWS::CloudFormation::Stack')
    Property('TemplateURL', FnJoin('', [
                                     Ref('BaseTemplateURL'),
                                     Ref('VPCCFNTemplateFile')
                                   ]))
    Property('TimeoutInMinutes', '60')
  end

  Resource('IAMStack') do
    Type('AWS::CloudFormation::Stack')
    Property('TemplateURL', FnJoin('', [
                                     Ref('BaseTemplateURL'),
                                     Ref('IAMCFNTemplateFile')
                                   ]))
    Property('TimeoutInMinutes', '60')
  end

  Resource('ENIStack') do
    Type('AWS::CloudFormation::Stack')
    DependsOn([
                'VPCStack'
              ])
    Property('TemplateURL', FnJoin('', [
                                     Ref('BaseTemplateURL'),
                                     Ref('ENICFNTemplateFile')
                                   ]))
    Property('TimeoutInMinutes', '60')
    Property('Parameters', 'Domain' => Ref('Domain'),
                           'Hostname' => Ref('AWS::StackName'),
                           'SubnetId' => FnGetAtt('VPCStack', 'Outputs.SubnetId'))
  end

  Resource('PipelineStoreStack') do
    Type('AWS::CloudFormation::Stack')
    DependsOn(%w(
                DynamoDBStack
                VPCStack
                IAMStack
                ZapStack
              ))
    Property('TemplateURL', FnJoin('', [
                                     Ref('BaseTemplateURL'),
                                     Ref('PipelineStoreCFNTemplateFile')
                                   ]))
    Property('TimeoutInMinutes', '60')
    Property('Parameters', 'Branch' => Ref('Branch'),
                           'ConfigStackName'       => FnIf('cEnableConfig', FnGetAtt('ConfigStack', 'Outputs.StackName'), Ref('AWS::NoValue')),
                           'DDBStackName'          => FnGetAtt('DynamoDBStack', 'Outputs.StackName'),
                           'DemoResultsBucket'     => Ref('pDemoResultsBucket'),
                           'DromedaryS3Bucket'     => Ref('AWS::AccountId'),
                           'ENIStackName'          => FnGetAtt('ENIStack', 'Outputs.StackName'),
                           'Hostname'              => Ref('AWS::StackName'),
                           'IAMStackName'          => FnGetAtt('IAMStack', 'Outputs.StackName'),
                           'KeyName'               => Ref('KeyName'),
                           'LambdaConfigStackName' => FnIf('cEnableConfig', FnGetAtt('LambdaConfigStack', 'Outputs.StackName'), Ref('AWS::NoValue')),
                           'MasterStackName'       => Ref('AWS::StackName'),
                           'ProdHostedZone'        => Ref('ProdHostedZone'),
                           'UUID'                  => Ref('AWS::StackName'),
                           'VPCStackName'          => FnGetAtt('VPCStack', 'Outputs.StackName'),
                           'ZapStackName'          => FnGetAtt('ZapStack', 'Outputs.StackName'))
  end

  Resource('ZapStack') do
    Type('AWS::CloudFormation::Stack')
    DependsOn(%w(
                VPCStack
                IAMStack
              ))
    Property('TemplateURL', FnJoin('', [
                                     Ref('BaseTemplateURL'),
                                     Ref('ZapCFNTemplateFile')
                                   ]))
    Property('TimeoutInMinutes', '60')
    Property('Parameters', 'CfnInitRole' => FnGetAtt('IAMStack', 'Outputs.InstanceRole'),
                           'Ec2Key'          => Ref('KeyName'),
                           'InstanceProfile' => FnGetAtt('IAMStack', 'Outputs.InstanceProfile'),
                           'SubnetId'        => FnGetAtt('VPCStack', 'Outputs.SubnetId'),
                           'VPC'             => FnGetAtt('VPCStack', 'Outputs.VPC'),
                           'pZapAmiId'       => Ref('pZapAmiId'))
  end

  Resource('JenkinsStack') do
    Type('AWS::CloudFormation::Stack')
    Metadata("conditionalOrderingHack": FnIf('cEnableConfig', FnGetAtt('LambdaConfigStack', 'Outputs.StackName'), 'dontcare'))
    DependsOn(%w(
                DynamoDBStack
                VPCStack
                IAMStack
                PipelineStoreStack
                WebServerInstance
              ))
    Property('TemplateURL', FnJoin('', [
                                     Ref('BaseTemplateURL'),
                                     Ref('JenkinsCFNTemplateFile')
                                   ]))
    Property('TimeoutInMinutes', '60')
    Property('Parameters', 'CfnInitRole' => FnGetAtt('IAMStack', 'Outputs.InstanceRole'),
                           'Ec2Key'            => Ref('KeyName'),
                           'InstanceProfile'   => FnGetAtt('IAMStack', 'Outputs.InstanceProfile'),
                           'JobConfigsTarball' => FnGetAtt('PipelineStoreStack', 'Outputs.JobConfigsTarball'),
                           'S3Bucket'          => FnGetAtt('PipelineStoreStack', 'Outputs.DromedaryS3Bucket'),
                           'SubnetId'          => FnGetAtt('VPCStack', 'Outputs.SubnetId'),
                           'VPC'               => FnGetAtt('VPCStack', 'Outputs.VPC'))
  end

  Resource('CodePipelineActionsStack') do
    Type('AWS::CloudFormation::Stack')
    DependsOn([
                'JenkinsStack'
              ])
    Property('TemplateURL', FnJoin('', [
                                     Ref('BaseTemplateURL'),
                                     Ref('CodePipelineActionsCFNTemplateFile')
                                   ]))
    Property('TimeoutInMinutes', '60')
    Property('Parameters', 'MyBuildProvider' => FnGetAtt('PipelineStoreStack', 'Outputs.MyBuildProvider'),
                           'MyJenkinsURL' => FnGetAtt('JenkinsStack', 'Outputs.JenkinsURL'))
  end

  Resource('CodePipelineStack') do
    Type('AWS::CloudFormation::Stack')
    DependsOn([
                'CodePipelineActionsStack'
              ])
    Property('TemplateURL', FnJoin('', [
                                     Ref('BaseTemplateURL'),
                                     Ref('CodePipelineCFNTemplateFile')
                                   ]))
    Property('TimeoutInMinutes', '60')
    Property('Parameters', 'ArtifactStoreBucket' => FnGetAtt('PipelineStoreStack', 'Outputs.DromedaryS3Bucket'),
                           'Branch'                  => Ref('Branch'),
                           'CodePipelineServiceRole' => FnGetAtt('IAMStack', 'Outputs.CodePipelineTrustRoleARN'),
                           'GitHubToken'             => Ref('GitHubToken'),
                           'GitHubUser'              => Ref('GitHubUser'),
                           'MyBuildProvider'         => FnGetAtt('PipelineStoreStack', 'Outputs.MyBuildProvider'),
                           'MyJenkinsURL'            => FnGetAtt('JenkinsStack', 'Outputs.JenkinsURL'),
                           'Repo'                    => Ref('Repo'))
  end

  Resource('ConfigStack') do
    Type('AWS::CloudFormation::Stack')
    Condition('cEnableConfig')
    DependsOn([])
    Property('TemplateURL', FnJoin('', [
                                     Ref('BaseTemplateURL'),
                                     Ref('ConfigCFNTemplateFile')
                                   ]))
    Property('TimeoutInMinutes', '60')
    Property('Parameters', {})
  end

  Resource('LambdaConfigStack') do
    Type('AWS::CloudFormation::Stack')
    Condition('cEnableConfig')
    DependsOn([
                'ConfigStack'
              ])
    Property('TemplateURL', FnJoin('', [
                                     Ref('BaseTemplateURL'),
                                     Ref('LambdaConfigCFNTemplateFile')
                                   ]))
    Property('TimeoutInMinutes', '60')
    Property('Parameters', {})
  end

  Resource('rCloudFrontStack') do
    Type('AWS::CloudFormation::Stack')
    Condition('cEnableCloudFrontAndWaf')
    Property('TemplateURL', FnJoin('', [
                                     Ref('BaseTemplateURL'),
                                     Ref('pCloudFrontCFNTemplateFile')
                                   ]))
    Property('TimeoutInMinutes', '60')
    Property('Parameters', 'pDistributionDomainName' => FnJoin('', [
                                                                 Ref('AWS::StackName'),
                                                                 '',
                                                                 Ref('ProdHostedZone')
                                                               ]))
  end

  Output('StackName') do
    Value(Ref('AWS::StackName'))
  end

  Output('DromedaryAppURL') do
    Value(FnJoin('', [
                   'http://',
                   FnGetAtt('PipelineStoreStack', 'Outputs.DromedaryAppURL'),
                   '/'
                 ]))
  end
end
