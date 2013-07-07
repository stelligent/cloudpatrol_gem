require 'aws'
require 'cloudpatrol/task/*.rb'

module Cloudpatrol
  module Task
    include ::AWS
  end
end
