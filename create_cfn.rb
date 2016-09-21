#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'config.rb'
require './lib/cfn_validate.rb'
require './lib/cfn_nag.rb'

require 'aws-sdk'
# require 'cfndsl/rake_task'

# template_directory = "pipeline/cfndsl"
# output_directory = "pipeline/cfn2"
#

puts "Looking for cfndsl files in #{PIPELINE_CFNDSL_FILES}"

Dir.glob("#{PIPELINE_CFNDSL_FILES}/*.rb") do |file|
  filebase = File.basename(file, File.extname(file))
  #  `cfn2dsl -t cfn/#{file} -o dsl/#{filebase}.rb`
  #  puts "cfn2dsl -t cfn/#{file} -o dsl/#{filebase}.rb"
  output_file = "#{PIPELINE_CFN_FILES}/#{filebase}.json"

  puts '---'
  puts "Creating #{output_file}"
  system("cfndsl --disable-binding #{file} -y pipeline/cfndsl/config.yaml | json_pp --no-color > #{output_file}")

  puts 'Validating JSON local file'
  #  system("aws --region #{AWS_REGION} --profile labs-admin cloudformation validate-template --template-body file://#{output_file}")

  # cloudformation = Aws::CloudFormation::Client.new(region: "us-east-1")
  #
  # cloudformation.validate_template({ template_body: "pipeline/cfn2/app-eni.json" })
  # region = "us-east-1"
  # body = "pipeline/cfn2/app-eni.json"
  #   cloudformation = Aws::CloudFormation::Client.new(region: AWS_REGION)
  #   cloudformation.validate_template({ template_body: body })
  #
  # puts resp
  check_valid_json = CfnValidate.new.validate_json(output_file)
  #  puts check_valid_json

  if check_valid_json == 'valid'
    puts 'JSON file is valid...Checking JSON file with cfn_nag'
    CfnNag.new.check_json_file(output_file)
    # check_cfn_nag = Cfn_nag.new.check_json_file(output_file)
  else
    puts "JSON file #{output_file} is not valid. Check file for errors"
  end

  #  system("ls -al #{file}")
end

# region = "us-east-1"
# body = "pipeline/cfn2/app-eni.json"
# cloudformation = Aws::CloudFormation::Client.new(region: region)
# cloudformation.validate_template({ template_body: body })
