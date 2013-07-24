require 'cloudpatrol/task.rb'
require 'cloudpatrol/version.rb'
require 'core_ext/integer.rb'

module Cloudpatrol
  def self.perform aws_credentials, table_name, klass, method, *args
    response = {}
    table_name ||= "cloudpatrol-log"

    response[:task] = begin
      response[:formatted] = Task.const_get(klass).new(aws_credentials).send(method, *args)
    rescue AWS::Errors::Base => e
      response[:formatted] = "AWS error: #{e}"
      false
    rescue
      response[:formatted] = "Unknown error"
      false
    end

    response[:log] = begin
      Task::DynamoDB.new(aws_credentials, table_name).log({ class: klass, method: method, args: args }, response[:formatted])
    rescue
      puts "Failed to write log to DynamoDB"
      false
    end

    response
  end

  def self.get_log aws_credentials, table_name = "cloudpatrol-log"
    gate = ::AWS::DynamoDB.new(aws_credentials)
    response = {}
    table = gate.tables[table_name]
    if table.exists?
      response[:log] = []
      table.items.each do |item|
        response[:log] << item.attributes.to_hash
      end
      response[:log].map! do |item|
        {
          time: Time.parse(item["time"]),
          action: item["action"],
          response: item["response"]
        }
      end
      response[:log].sort!{ |x,y| y[:time] <=> x[:time] }
    else
      response[:success] = false
      response[:error] = "Table doesn't exist"
    end
  rescue AWS::Errors::Base => e
    response[:success] = false
    response[:error] = "AWS error: #{e}"
  rescue
    response[:success] = false
    response[:error] = "Unknown error"
  else
    response[:success] = if response[:log].empty?
      response[:error] = "Log is empty"
      false
    else
      true
    end
  ensure
    return response
  end
end
