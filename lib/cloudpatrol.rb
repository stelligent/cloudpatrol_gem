require 'cloudpatrol/task.rb'
require 'cloudpatrol/version.rb'
require 'core_ext/integer.rb'

module Cloudpatrol
  def self.perform aws_credentials, table_name, klass, method, *args
    response = {}
    table_name = "cloudpatrol-log" unless table_name
    (response[:task] = Task.const_get(klass).new(aws_credentials).send(method, *args)) rescue false
    (response[:log] = Task::DynamoDB.new(aws_credentials).log(table_name, { class: klass, method: method, args: args }, response[:task])) rescue false
    response
  end
end
