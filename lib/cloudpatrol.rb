require 'cloudpatrol/task.rb'
require 'cloudpatrol/version.rb'
require 'core_ext/integer.rb'

module Cloudpatrol
  def self.perform aws_credentials, klass, method, *args
    Task.config aws_credentials

    response = {}
    response[:task] = Task::klass.new.send(method, *args)
    response[:log] = Task::DynamoDB.new.log({ klass: klass, method: method, args: args }, response[:task])
    response
  end
end
