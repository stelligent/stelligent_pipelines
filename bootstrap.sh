#!/bin/bash -x
set -o pipefail

EC2_KEY_PAIR_NAME=xxxx
HOSTED_ZONE_NAME=xxx.com
DYNAMODB_TABLE_NAME=xxxxx
GITHUB_TOKEN=xxxx
GITHUB_USER=xxxx
AWS_REGION=xxxx

which jq
if [[ $? != 0 ]];
then
  echo "jq must be installed - on a mac: brew install jq"
  exit 1
fi

key_pair_count=$(aws ec2 describe-key-pairs --key-names ${EC2_KEY_PAIR_NAME} --region ${AWS_REGION} | jq '.KeyPairs|length')
if [[ ${key_pair_count} == 0 ]];
then
  set -e
  aws ec2 create-key-pair --key-name ${EC2_KEY_PAIR_NAME} \
                          --region ${AWS_REGION} \
                          | jq '.KeyMaterial' \
                          | ruby -e 'puts STDIN.read.gsub(/"/,"").gsub(/\\n/,"\n")' > ${EC2_KEY_PAIR_NAME}.pem
fi

hosted_zone_count=$(aws route53 list-hosted-zones-by-name --dns-name ${HOSTED_ZONE_NAME} | jq '.HostedZones|length')
if [[ ${hosted_zone_count} == 0 ]];
then
  set -e
  aws route53 create-hosted-zone --name ${HOSTED_ZONE_NAME} \
                                 --caller-reference $(date +'%m-%d-%Y') \
                                 --hosted-zone-config Comment="for dromedary hacking"
fi

aws cloudformation create-stack \
--stack-name DromedaryStack  \
--template-body https://raw.githubusercontent.com/stelligent/dromedary/master/pipeline/cfn/dromedary-master.json \
--region ${AWS_REGION} \
--disable-rollback --capabilities="CAPABILITY_IAM" \
--parameters ParameterKey=KeyName,ParameterValue=${EC2_KEY_PAIR_NAME} \
	ParameterKey=Branch,ParameterValue=master \
	ParameterKey=BaseTemplateURL,ParameterValue=https://s3.amazonaws.com/stelligent-training-public/master/ \
	ParameterKey=GitHubUser,ParameterValue=${GITHUB_USER} \
	ParameterKey=GitHubToken,ParameterValue=${GITHUB_TOKEN} \
	ParameterKey=DDBTableName,ParameterValue=${DYNAMODB_TABLE_NAME} \
	ParameterKey=ProdHostedZone,ParameterValue=.${HOSTED_ZONE_NAME} \
	ParameterKey=Domain,ParameterValue=${HOSTED_ZONE_NAME}.