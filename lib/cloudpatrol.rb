require 'cloudpatrol/task.rb'
require 'cloudpatrol/version.rb'
require 'core_ext/integer.rb'

module Cloudpatrol
  def self.perform aws_credentials, table_name, klass, method, *args
    response = {}
    table_name ||= "cloudpatrol-log"

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
      Task::DynamoDB.new(aws_credentials, table_name).log({ class: klass, method: method, args: args }, aws_response)
    rescue
      puts "Failed to write log to DynamoDB"
      false
    end

    response
  end

  def self.get_log aws_credentials, table_name = "cloudpatrol-log"
    gate = ::AWS::DynamoDB.new(aws_credentials)
    response = []
    table = gate.tables[table_name]
    if table.exists?
      table.items.each do |item|
        response << item.attributes.to_hash
      end
      response.map! do |item|
        {
          time: Time.parse(item["time"]),
          action: item["action"],
          response: item["response"]
        }
      end
      response.sort!{ |x,y| y[:time] <=> x[:time] }
    else
      response = "Table doesn't exist"
    end
    response
  rescue
    "Unknown error"
  end
end
