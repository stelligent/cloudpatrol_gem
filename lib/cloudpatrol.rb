require 'cloudpatrol/task.rb'
require 'cloudpatrol/version.rb'
require 'core_ext/integer.rb'

module Cloudpatrol
  def self.perform aws_credentials, table_name, klass, method, *args
    response = {}
    table_name = "cloudpatrol-log" unless table_name

    aws_response = begin
      response[:task] = Task.const_get(klass).new(aws_credentials).send(method, *args)
    rescue AWS::Errors::Base => e
      response[:task] = false
      "AWS error: #{e}"
    rescue
      response[:task] = false
      "Unknown error"
    end

    response[:log] = begin
      Task::DynamoDB.new(aws_credentials).log(table_name, { class: klass, method: method, args: args }, aws_response)
    rescue
      puts "Failed to write log to DynamoDB"
      false
    end

    response
  end
end
