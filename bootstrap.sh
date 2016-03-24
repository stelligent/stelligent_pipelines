#!/bin/bash -x
set -o pipefail

# env variables

# Name of EC2 keypair to use for instances
EC2_KEY_PAIR_NAME=${EC2_KEY_PAIR_NAME:-xxxx}
# Domain name (e.g. example.com) that is in a
# Route53 hosted zone to use for this deployment
HOSTED_ZONE_NAME=${HOSTED_ZONE_NAME:-xxx.com}
# DynamoDB table to use for pipeline state storage
DYNAMODB_TABLE_NAME=${DYNAMODB_TABLE_NAME:-xxxxx}
# GitHub token and user to use to poll and retrieve
# application code repository
GITHUB_TOKEN=${GITHUB_TOKEN:-xxxx}
GITHUB_USER=${GITHUB_USER:-xxxx}
# Repository branch to use for CodePipeline's
# Source action
APP_REPO_BRANCH=${APP_REPO_BRANCH:-master}
# AWS Region to launch pipeline in
# Region must support
# * CodePipeline
# * Config Rules
# * Lambda
AWS_REGION=${AWS_REGION:-us-east-1}
# S3 Buckeet to create and store pipeline assets
# such as CloudFormation templates in
DEV_BUCKET=${DEV_BUCKET:-xxxx}
# Whether to update AWS Lambda functions with new code
ENABLE_CONFIG=${ENABLE_CONFIG:-false}
# S3 bucket for Dromedary application resources
# XXX remove
DROMEDARY_BUCKET=${DROMEDARY_BUCKET:-xxxx} #for example in goldbase it would be:  dromedary-592804526322
# AMI ID for launching ZAP server
ZAP_AMI_ID=${ZAP_AMI_ID:-ami-cdb588a7}
# CloudFormation stack name for pipeline
STACK_NAME=${STACK_NAME:-DromedaryStack}
# Internally used URL to DEV_BUCKET S3 resources
BASE_TEMPLATE_URL="https://s3.amazonaws.com/${DEV_BUCKET}/"

# Create $DEV_BUCKET
# XXX no check for existence
aws s3api create-bucket --bucket ${DEV_BUCKET}
aws s3api create-bucket --bucket ${DROMEDARY_BUCKET}

# Upload all needed cloudformation templates to DEV_BUCKET
# XXX these templates should have a key prefix like cfn/
for json in $(ls pipeline/cfn/*.json);
do
  aws s3 cp ${json} s3://${DEV_BUCKET}/
done

# Ensure jq utility is installed, if not bail
which jq
if [[ $? != 0 ]];
then
  echo "jq must be installed - on a mac: brew install jq"
  exit 1
fi

# Ensure $EC2_KEY_PAIR_NAME exists in EC2. If not, generate a
# new keypair by that name and store the private key to
# ${EC2_KEY_PAIR_NAME}.pem
aws ec2 describe-key-pairs --key-names ${EC2_KEY_PAIR_NAME} --region ${AWS_REGION} | jq '.KeyPairs|length'
if [[ $? != 0 ]];
then
  set -e
  aws ec2 create-key-pair --key-name ${EC2_KEY_PAIR_NAME} \
                          --region ${AWS_REGION} \
                          | jq '.KeyMaterial' \
                          | ruby -e 'puts STDIN.read.gsub(/"/,"").gsub(/\\n/,"\n")' > ${EC2_KEY_PAIR_NAME}.pem
fi

# If a hosted zone does not exist that matches the name in
# $HOSTED_ZONE_NAME, create a new zone
hosted_zone_count=$(aws route53 list-hosted-zones-by-name --dns-name ${HOSTED_ZONE_NAME} | jq '.HostedZones|length')
if [[ ${hosted_zone_count} == 0 ]];
then
  set -e
  aws route53 create-hosted-zone --name ${HOSTED_ZONE_NAME} \
                                 --caller-reference $(date +'%m-%d-%Y') \
                                 --hosted-zone-config Comment="for dromedary hacking"
fi

# zip up the security rules in test-security-integration/lambda/*
# and upload to s3://${DROMEDARY_BUCKET}/lambda/
pushd test-security-integration/lambda
zip -r config-rules.zip *
aws s3 cp config-rules.zip s3://${DROMEDARY_BUCKET}/lambda/
rm config-rules.zip
popd

#update the lambdas if ENABLE_CONFIG=false
if [[ "$ENABLE_CONFIG" = "false" ]]; then
    echo "Update the lambdas with the new code:"
    for func in `aws lambda list-functions | jq -c '.Functions[] | select(.FunctionName | startswith("'"${STACK_NAME:0:25}"'"))? | {FunctionName} | .FunctionName'`
    do
        echo "aws lambda update-function-code --function-name ${func} --s3-bucket ${DROMEDARY_BUCKET} --s3-key lambda/config-rules.zip --publish" | sh
    done
fi

# Launch pipeline-master.json as a new CloudFormation stack
# XXX pipeline-master.json should be uploaded into S3 already,
# refer to it with template-url instead
aws cloudformation create-stack \
--stack-name ${STACK_NAME}  \
--template-body file://pipeline/cfn/pipeline-master.json \
--region ${AWS_REGION} \
--disable-rollback --capabilities="CAPABILITY_IAM" \
--parameters \
  ParameterKey=KeyName,ParameterValue=${EC2_KEY_PAIR_NAME} \
  ParameterKey=pZapAmiId,ParameterValue=${ZAP_AMI_ID} \
	ParameterKey=Branch,ParameterValue=${APP_REPO_BRANCH} \
	ParameterKey=BaseTemplateURL,ParameterValue=${BASE_TEMPLATE_URL} \
	ParameterKey=GitHubUser,ParameterValue=${GITHUB_USER} \
	ParameterKey=GitHubToken,ParameterValue=${GITHUB_TOKEN} \
	ParameterKey=DDBTableName,ParameterValue=${DYNAMODB_TABLE_NAME} \
	ParameterKey=ProdHostedZone,ParameterValue=.${HOSTED_ZONE_NAME} \
	ParameterKey=pEnableConfig,ParameterValue=.${ENABLE_CONFIG} \
	ParameterKey=Domain,ParameterValue=${HOSTED_ZONE_NAME}.
