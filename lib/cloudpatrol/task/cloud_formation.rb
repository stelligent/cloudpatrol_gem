require 'aws'

module Cloudpatrol
  module Task
    class CloudFormation
      def initialize cred
        @gate = ::AWS::CloudFormation.new(cred)
      end

      def clean_stacks allowed_age
        deleted = []
        @gate.stacks.each do |stack|
          if (Time.now - stack.creation_time).to_i > allowed_age.days
            deleted << stack
            stack.delete
          end
        end
        deleted
      end
    end
  end
end
