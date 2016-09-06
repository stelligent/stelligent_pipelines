#!/usr/bin/env ruby

require 'aws-sdk'

require_relative 'config.rb'

def cfn_validate(json_file)
  cloudformation = Aws::CloudFormation::Client.new(region:AWS_REGION)
  begin
    file = File.open(json_file, "r")
    data = file.read
    resp = cloudformation.validate_template({ template_body: data })
    file.close
    puts "JSON file #{json_file} is valid"
  rescue
    puts "JSON file #{json_file} is not valid"
  end
end

json_file = "pipeline/cfn2/app-eni.json"

cfn_validate(json_file)
# file = "pipeline/cfn2/app-eni.json"
# read = File.read(file)
# resp = cloudformation.validate_template(read)



# cloudformation.validate_template({ template_body: "file://./pipeline/cfn2/app-eni.json" })
