# frozen_string_literal: true
CloudFormation do
  Description('Dromedary CodePipeline provisioning')
  AWSTemplateFormatVersion('2010-09-09')

  Parameter('ArtifactStoreBucket') do
    Description('S3 bucket to use for artifacts. Just bucket Name; not URL. IAM user should have access to the bucket.')
    Type('String')
    Default('codepipeline-us-east-1-XXXXXXXXXXX')
  end

  Parameter('GitHubToken') do
    Description('Secret. It might look something like 9b189a1654643522561f7b3ebd44a1531a4287af OAuthToken with access to Repo. Go to https://github.com/settings/tokens')
    Type('String')
    NoEcho(true)
  end

  Parameter('GitHubUser') do
    Description('GitHub UserName')
    Type('String')
    Default('stelligent')
  end

  Parameter('Repo') do
    Description('GitHub Repo to pull from. Only the Name. not the URL')
    Type('String')
    Default('dromedary')
  end

  Parameter('Branch') do
    Description('Branch to use from Repo. Only the Name. not the URL')
    Type('String')
    Default('master')
  end

  Parameter('MyInputArtifacts') do
    Type('String')
    Default('DromedarySource')
  end

  Parameter('MyBuildProvider') do
    Description('Unique identifier for Custom Action')
    Type('String')
  end

  Parameter('MyJenkinsURL') do
    Type('String')
  end

  Parameter('CodePipelineServiceRole') do
    Description('This IAM role must have proper permissions.')
    Type('String')
    Default('arn:aws:iam::123456789012:role/AWS-CodePipeline-Service')
  end

  Resource('AppPipeline') do
    Type('AWS::CodePipeline::Pipeline')
    Property('RoleArn', Ref('CodePipelineServiceRole'))
    Property('Stages', [
               {
                 'Actions' => [
                   {
                     'ActionTypeId' => {
                       'Category' => 'Source',
                       'Owner'    => 'ThirdParty',
                       'Provider' => 'GitHub',
                       'Version'  => '1'
                     },
                     'Configuration' => {
                       'Branch'     => Ref('Branch'),
                       'OAuthToken' => Ref('GitHubToken'),
                       'Owner'      => Ref('GitHubUser'),
                       'Repo'       => Ref('Repo')
                     },
                     'InputArtifacts'  => [],
                     'Name'            => 'Source',
                     'OutputArtifacts' => [
                       {
                         'Name' => Ref('MyInputArtifacts')
                       }
                     ],
                     'RunOrder'        => 1
                   },
                   {
                     'ActionTypeId'    => {
                       'Category' => 'Source',
                       'Owner'    => 'ThirdParty',
                       'Provider' => 'GitHub',
                       'Version'  => '1'
                     },
                     'Configuration' => {
                       'Branch'     => 'master',
                       'OAuthToken' => Ref('GitHubToken'),
                       'Owner'      => 'stelligent',
                       'Repo'       => 'stelligent_pipelines'
                     },
                     'InputArtifacts'  => [],
                     'Name'            => 'PipelineSource',
                     'OutputArtifacts' => [
                       {
                         'Name' => 'PipelineArtifact'
                       }
                     ],
                     'RunOrder' => 1
                   }
                 ],
                 'Name' => 'Source'
               },
               {
                 'Actions' => [
                   {
                     'ActionTypeId' => {
                       'Category' => 'Build',
                       'Owner'    => 'Custom',
                       'Provider' => Ref('MyBuildProvider'),
                       'Version'  => '1'
                     },
                     'Configuration' => {
                       'ProjectName' => 'drom-build'
                     },
                     'InputArtifacts' => [
                       {
                         'Name' => Ref('MyInputArtifacts')
                       },
                       {
                         'Name' => 'PipelineArtifact'
                       }
                     ],
                     'Name'            => 'Build',
                     'OutputArtifacts' => [
                       {
                         'Name' => 'DromedaryBuild'
                       }
                     ],
                     'RunOrder'        => 1
                   },
                   {
                     'ActionTypeId'    => {
                       'Category' => 'Test',
                       'Owner'    => 'Custom',
                       'Provider' => Ref('MyBuildProvider'),
                       'Version'  => '1'
                     },
                     'Configuration' => {
                       'ProjectName' => 'drom-unit-test'
                     },
                     'InputArtifacts' => [
                       {
                         'Name' => Ref('MyInputArtifacts')
                       },
                       {
                         'Name' => 'PipelineArtifact'
                       }
                     ],
                     'Name'            => 'UnitTest',
                     'OutputArtifacts' => [],
                     'RunOrder'        => 1
                   },
                   {
                     'ActionTypeId'    => {
                       'Category' => 'Test',
                       'Owner'    => 'Custom',
                       'Provider' => Ref('MyBuildProvider'),
                       'Version'  => '1'
                     },
                     'Configuration' => {
                       'ProjectName' => 'drom-staticcode-anal'
                     },
                     'InputArtifacts' => [
                       {
                         'Name' => Ref('MyInputArtifacts')
                       },
                       {
                         'Name' => 'PipelineArtifact'
                       }
                     ],
                     'Name'            => 'StaticCodeAnalysis',
                     'OutputArtifacts' => [],
                     'RunOrder'        => 1
                   },
                   {
                     'ActionTypeId'    => {
                       'Category' => 'Test',
                       'Owner'    => 'Custom',
                       'Provider' => Ref('MyBuildProvider'),
                       'Version'  => '1'
                     },
                     'Configuration' => {
                       'ProjectName' => 'drom-sec-static-anal'
                     },
                     'InputArtifacts' => [
                       {
                         'Name' => Ref('MyInputArtifacts')
                       },
                       {
                         'Name' => 'PipelineArtifact'
                       }
                     ],
                     'Name'            => 'SecStaticCodeAnalysis',
                     'OutputArtifacts' => [],
                     'RunOrder'        => 1
                   }
                 ],
                 'Name'    => 'Commit'
               },
               {
                 'Actions' => [
                   {
                     'ActionTypeId'    => {
                       'Category' => 'Test',
                       'Owner'    => 'Custom',
                       'Provider' => Ref('MyBuildProvider'),
                       'Version'  => '1'
                     },
                     'Configuration' => {
                       'ProjectName' => 'drom-create-env'
                     },
                     'InputArtifacts' => [
                       {
                         'Name' => 'DromedaryBuild'
                       }
                     ],
                     'Name'            => 'CreateEnvironment',
                     'OutputArtifacts' => [
                       {
                         'Name' => 'DromedaryCreate'
                       }
                     ],
                     'RunOrder'        => 1
                   },
                   {
                     'ActionTypeId'    => {
                       'Category' => 'Test',
                       'Owner'    => 'Custom',
                       'Provider' => Ref('MyBuildProvider'),
                       'Version'  => '1'
                     },
                     'Configuration' => {
                       'ProjectName' => 'drom-acceptance-test'
                     },
                     'InputArtifacts' => [
                       {
                         'Name' => 'DromedaryCreate'
                       }
                     ],
                     'Name'            => 'AcceptanceTest',
                     'OutputArtifacts' => [
                       {
                         'Name' => 'DromedaryAccepted'
                       }
                     ],
                     'RunOrder'        => 2
                   },
                   {
                     'ActionTypeId'    => {
                       'Category' => 'Test',
                       'Owner'    => 'Custom',
                       'Provider' => Ref('MyBuildProvider'),
                       'Version'  => '1'
                     },
                     'Configuration' => {
                       'ProjectName' => 'drom-pen-test'
                     },
                     'InputArtifacts' => [
                       {
                         'Name' => 'DromedaryCreate'
                       }
                     ],
                     'Name'            => 'AutomatedPenTest',
                     'OutputArtifacts' => [
                       {
                         'Name' => 'DromedaryPenTest'
                       }
                     ],
                     'RunOrder' => 2
                   },
                   {
                     'ActionTypeId' => {
                       'Category' => 'Test',
                       'Owner'    => 'Custom',
                       'Provider' => Ref('MyBuildProvider'),
                       'Version'  => '1'
                     },
                     'Configuration' => {
                       'ProjectName' => 'drom-infra-test'
                     },
                     'InputArtifacts' => [
                       {
                         'Name' => 'DromedaryCreate'
                       }
                     ],
                     'Name'            => 'InfrastructureTest',
                     'OutputArtifacts' => [
                       {
                         'Name' => 'DromedaryInfra'
                       }
                     ],
                     'RunOrder'        => 2
                   },
                   {
                     'ActionTypeId'    => {
                       'Category' => 'Test',
                       'Owner'    => 'Custom',
                       'Provider' => Ref('MyBuildProvider'),
                       'Version'  => '1'
                     },
                     'Configuration' => {
                       'ProjectName' => 'drom-sec-int-test'
                     },
                     'InputArtifacts' => [
                       {
                         'Name' => 'DromedaryCreate'
                       }
                     ],
                     'Name'            => 'SecurityIntegrationTest',
                     'OutputArtifacts' => [
                       {
                         'Name' => 'DromedarySecure'
                       }
                     ],
                     'RunOrder' => 3
                   },
                   {
                     'ActionTypeId' => {
                       'Category' => 'Test',
                       'Owner'    => 'Custom',
                       'Provider' => Ref('MyBuildProvider'),
                       'Version'  => '1'
                     },
                     'Configuration' => {
                       'ProjectName' => 'drom-trusted-advisor'
                     },
                     'InputArtifacts' => [
                       {
                         'Name' => 'DromedaryBuild'
                       }
                     ],
                     'Name' => 'TrustedAdvisor'
                   }
                 ],
                 'Name'    => 'Acceptance'
               },
               {
                 'Actions' => [
                   {
                     'ActionTypeId' => {
                       'Category' => 'Test',
                       'Owner'    => 'Custom',
                       'Provider' => Ref('MyBuildProvider'),
                       'Version'  => '1'
                     },
                     'Configuration' => {
                       'ProjectName' => 'drom-promote-env'
                     },
                     'InputArtifacts' => [
                       {
                         'Name' => 'DromedaryAccepted'
                       }
                     ],
                     'Name'            => 'PromoteEnvironment',
                     'OutputArtifacts' => [],
                     'RunOrder'        => 1
                   }
                 ],
                 'Name' => 'Production'
               }
             ])
    Property('ArtifactStore', 'Location' => Ref('ArtifactStoreBucket'),
                              'Type' => 'S3')
  end

  Output('StackName') do
    Value(Ref('AWS::StackName'))
  end
end
