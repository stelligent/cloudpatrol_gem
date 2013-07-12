require 'cloudpatrol/task.rb'
require 'cloudpatrol/version.rb'
require 'core_ext/integer.rb'

module Cloudpatrol
  def self.perform aws_credentials, table_name, klass, method, *args
    response = {}
    table_name = "cloudpatrol-log" if table_name.blank?
    response[:task] = Task.const_get(klass).new(aws_credentials).send(method, *args)
    response[:log] = Task::DynamoDB.new(aws_credentials).log(table_name, { klass: klass, method: method, args: args }, response[:task])
    response
  end
end
