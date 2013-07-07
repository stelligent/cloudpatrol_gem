require 'cloudpatrol/task.rb'
require 'cloudpatrol/version.rb'
require 'core_ext/integer.rb'

module Cloudpatrol
  def self.perform aws_credentials, klass, method, *args
    response = {}
    response[:task] = Task.const_get(klass).new(aws_credentials).send(method, *args)
    response[:log] = Task::DynamoDB.new.log({ klass: klass, method: method, args: args }, response[:task])
    response
  end
end
