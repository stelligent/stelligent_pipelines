# frozen_string_literal: true
#
require 'aws-sdk'
require_relative '../config.rb'

# CfnValidate validates JSON files
class CfnValidate
  def validate_json(json_file)
    cloudformation = Aws::CloudFormation::Client.new(region: AWS_REGION)
    begin
      file = File.open(json_file, 'r')
      data = file.read
      cloudformation.validate_template(template_body: data)
      # resp = cloudformation.validate_template(template_body: data)
      # puts resp
      file.close
      #      puts "JSON file #{json_file} is valid"
      #      valid_file = 'yes'
      return 'valid'
    rescue
      #      puts "JSON file #{json_file} is not valid"
      return 'error'
    end
  end
end
#
# json_file = "pipeline/cfn2/app-eni.json"
#
# cfn_validate(json_file)
# file = "pipeline/cfn2/app-eni.json"
# read = File.read(file)
# resp = cloudformation.validate_template(read)

# cloudformation.validate_template({ template_body: "file://./pipeline/cfn2/app-eni.json" })
