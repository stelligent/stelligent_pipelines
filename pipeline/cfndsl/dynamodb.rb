# frozen_string_literal: true
CloudFormation do
  Description('Dromedary demo - DynamoDB Table')
  AWSTemplateFormatVersion('2010-09-09')

  Parameter('ReadCapacityUnits') do
    Description('Provisioned Read Capacity Units')
    Type('Number')
    Default('5')
  end

  Parameter('WriteCapacityUnits') do
    Description('Provisioned Write Capacity Units')
    Type('Number')
    Default('5')
  end

  Parameter('DDBTableName') do
    Description('Unique name for the Dromedary Dynamo DB table')
    Type('String')
  end

  Resource('Table') do
    Type('AWS::DynamoDB::Table')
    Property('TableName', Ref('DDBTableName'))
    Property('AttributeDefinitions', [
               {
                 'AttributeName' => 'site_name',
                 'AttributeType' => 'S'
               },
               {
                 'AttributeName' => 'color_name',
                 'AttributeType' => 'S'
               }
             ])
    Property('KeySchema', [
               {
                 'AttributeName' => 'site_name',
                 'KeyType'       => 'HASH'
               },
               {
                 'AttributeName' => 'color_name',
                 'KeyType'       => 'RANGE'
               }
             ])
    Property('ProvisionedThroughput',                'ReadCapacityUnits' => Ref('ReadCapacityUnits'),
                                                     'WriteCapacityUnits' => Ref('WriteCapacityUnits'))
  end

  Output('StackName') do
    Value(Ref('AWS::StackName'))
  end

  Output('TableName') do
    Description('Name of DynamoDB Table')
    Value(Ref('Table'))
  end
end
