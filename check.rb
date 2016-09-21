#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'config.rb'
require './lib/cfn_validate.rb'
require './lib/cfn_nag.rb'

require 'aws-sdk'
# require 'cfndsl/rake_task'

# template_directory = "pipeline/cfndsl"
# output_directory = "pipeline/cfn2"

output_file = 'pipeline/cfn/pipeline-master.json'
check_valid_json = Cfn_validate.new.validate_json(output_file)
puts check_valid_json
