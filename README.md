stelligent\_pipelines
=====================

Create CI/CD pipelines, the Stelligent Way

This repository contains infrastructure code to provision new
CI/CD pipelines of various flavors, and the code comprising
the pipeline logic itself.

ConSec Dromedary Pipeline
-------------------------

This pipeline was historically part of the dromedary repository,
and was used to spin up the CI/CD environment necessary to demo
automatic handling of changes to dromedary. It was enhanced
(being on the consec branch) with security scanning capabilities
as well.

*NOTE*: this pipeline is still tightly coupled with the Dromedary
demo app, and is not immediately suitable for use with other
applications.

Usage:

Create a text file (such as ../pipeline.env) with overrides for
environment variables used in bootstrap.sh

Example environment file:

    export EC2_KEY_PAIR_NAME=jeff-labs
    export ZAP_AMI_ID=ami-824a45e8
    export HOSTED_ZONE_NAME=demo.elasticoperations.com
    export DYNAMODB_TABLE_NAME=consecjlb
    export GITHUB_TOKEN=db50...
    export GITHUB_USER=stelligent
    export AWS_REGION=us-east-1
    export DEV_BUCKET=consecdemojlb
    export BASE_TEMPLATE_URL=https://s3.amazonaws.com/${DEV_BUCKET}/
    export ENABLE_CONFIG=false
    export DROMEDARY_BUCKET=consecconfigjlb
    export STACK_NAME=ConSecDemoJLB
    export ENABLE_CONFIG=false
    export APP_REPO_BRANCH="consec"
    export PIPELINES_REPO_BRANCH="master"
    export DEMO_RESULTS_BUCKET="demojlb.stelligent-continuous-security.com"


Source the file, then run bootstrap.sh:

    . ../pipeline.env;./bootstrap.sh
