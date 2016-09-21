# frozen_string_literal: true
# ruby
require 'cfndsl/rake_task'
require_relative './config.rb'

sample = 'zap-instance'
filename = "pipeline/cfndsl/#{sample}.rb"
output_file = "pipeline/cfn2/#{sample}.json"

task :create_json_files do
  CfnDsl::RakeTask.new do |t|
    t.cfndsl_opts = {
      verbose: true,
      pretty: true,
      files: [{
        filename: filename,
        output: output_file
      }]
    }
  end
  puts "blah #{@filename}"
end

task :test do
  puts 'Done'
end

# CfnDsl::RakeTask.new do |t|
#   t.cfndsl_opts = {
#     verbose: true,
#     pretty: true,
#     files: [{
#       filename: @filename,
#       output: @output_file
#     }]
#   }
# end

task default: [:create_json_files]
