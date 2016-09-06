#!/usr/bin/env ruby

require_relative 'config.rb'

require 'aws-sdk'

template_directory = "pipeline/cfndsl"
output_directory = "pipeline/cfn2"

Dir.glob("#{template_directory}/*.rb") do |file|
  filebase = File.basename(file,File.extname(file))
#  `cfn2dsl -t cfn/#{file} -o dsl/#{filebase}.rb`
#  puts "cfn2dsl -t cfn/#{file} -o dsl/#{filebase}.rb"
  output_file = "#{output_directory}/#{filebase}.json"

  puts "Creating #{output_file}"
  system("cfndsl --disable-binding #{file} | json_pp --no-color > #{output_file}")

  puts "Validating JSON local file"
  # system("aws --region #{AWS_REGION} --profile labs-admin cloudformation validate-template --template-body file://#{output_file}")

  # cloudformation = Aws::CloudFormation::Client.new(region: "us-east-1")
  #
  # cloudformation.validate_template({ template_body: "pipeline/cfn2/app-eni.json" })
  # region = "us-east-1"
  # body = "pipeline/cfn2/app-eni.json"
  # cloudformation = Aws::CloudFormation::Client.new(region: region)
  # cloudformation.validate_template({ template_body: body })

  # puts resp

  # puts "Checking JSON with cfn_nag"
  # system("cfn_nag -i #{output_file}")
  #
#  system("ls -al #{file}")
end


# region = "us-east-1"
# body = "pipeline/cfn2/app-eni.json"
# cloudformation = Aws::CloudFormation::Client.new(region: region)
# cloudformation.validate_template({ template_body: body })
