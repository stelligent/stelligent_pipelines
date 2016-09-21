#!/usr/bin/env ruby
# frozen_string_literal: true

require 'aws-sdk'

require_relative '../config.rb'

# CfnNag runs cfn_nag on json file sent to Class
class CfnNag
  def check_json_file(json_file)
    system("cfn_nag -i #{json_file}")
  end
end
