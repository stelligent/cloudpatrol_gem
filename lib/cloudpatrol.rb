require 'cloudpatrol/task.rb'
require 'cloudpatrol/version.rb'
require 'core_ext/integer.rb'

module Cloudpatrol
  class << self
    def perform(aws_credentials, table_name, klass, method, *args)
      response = {}
      table_name ||= "cloudpatrol-log"
      regions = Array(aws_credentials.delete(:region) || self.regions)

      regions.each do |region|
        this_region_credentials = aws_credentials.merge(region: region)

        begin
          response[:formatted], response[:failures] = response[:task] = Task.const_get(klass).new(this_region_credentials).send(method, *args)
        rescue AWS::Errors::Base => e
          response[:formatted] = "AWS error: #{e}"
          response[:task] = false
        rescue Exception => e
          response[:formatted] = "Unknown error: #{e}"
          response[:task] = false
        end

        response[:log] = begin
          Task::DynamoDB.new(this_region_credentials, table_name).log({ class: klass, method: method, args: args }, response[:formatted])
        rescue
          puts "Failed to write log to DynamoDB"
          false
        end
      end

      response
    end

    def get_log(aws_credentials, table_name="cloudpatrol-log")
      response = {}
      regions = Array(aws_credentials.delete(:region) || self.regions)

      regions.each do |region|
        this_region_credentials = aws_credentials.merge(region: region)

        gate = ::AWS::DynamoDB.new(this_region_credentials)
        table = gate.tables[table_name]
        if table.exists? and table.status == :active
          table.load_schema
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

    # Returns every available AWS region code.
    #
    # => ["us-east-1", "us-west-1", "us-west-2", "ap-northeast-1", "ap-southeast-1", "ap-southeast-2", "sa-east-1", "eu-west-1", "cn-north-1"]
    def regions
      AWS.regions.map(&:name)
    end
  end
end
