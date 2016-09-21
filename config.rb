#!/usr/bin/env ruby
# frozen_string_literal: true

# Name of EC2 keypair to use for instances
EC2_KEY_PAIR_NAME = 'tasker-labs-west-2-test'

# Domain name (e.g. example.com) that is in a
# Route53 hosted zone to use for this deployment
HOSTED_ZONE_NAME = 'tasker.elasticoperations.com'

# DynamoDB table to use for pipeline state storage
DYNAMODB_TABLE_NAME = 'tasker_ddb'

# GitHub user and toekn to use to poll and retrieve
# application code repository
## User should be stelligent
GITHUB_USER = 'stelligent'
GITHUB_TOKEN = '3ec10df5b66c68afb7fe0506857a593f459606f4'

# Repository branch to use for CodePipeline's
# Source action
APP_REPO_BRANCH = 'consec'

# Repository branch to use for pipeline construction
# (e.g. of stelligent_pipelines repo)
PIPELINES_REPO_BRANCH = 'master'

# AWS Region to launch pipeline in
# Region must support
# * CodePipeline
# * Config Rules
# * Lambda
AWS_REGION = 'us-east-1'

# S3 Buckeet to create and store pipeline assets
# such as CloudFormation templates in
DEV_BUCKET = 'tasker_drom_dev'

# JSON location
PIPELINE_CFN_FILES = 'pipeline/cfn'

PIPELINE_CFNDSL_FILES = 'pipeline/cfndsl'

# S3 bucket for Dromedary application resources
DROMEDARY_BUCKET = 'tasker_drom'

# Security Rules location
SECURITY_RULES_FILES = 'test-security-integration/lambda'

# Security Rules Zip file
SECURITY_RULES_ZIP = 'config-rules.zip'

# S3 bucket for Dromedary pipeline results for demo
DEMO_RESULTS_BUCKET = 'tasker_drom.stelligent-continuous-security.com'

# AMI ID for launching ZAP server
ZAP_AMI_ID = 'ami-824a45e8'

# CloudFormation stack name for pipeline
STACK_NAME = 'TaskerDromedary'
# STACK_NAME = "bettingerTest"

# Internally used URL to DEV_BUCKET S3 resources
BASE_TEMPLATE_URL = "https://s3.amazonaws.com/#{DEV_BUCKET}/"

# Configure system
ENABLE_CONFIG = 'false'
