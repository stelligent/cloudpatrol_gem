require 'aws'
require 'task/*.rb'

module Cloudpatrol
  module Task
    include ::AWS
  end
end
