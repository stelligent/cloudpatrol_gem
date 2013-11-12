require 'aws'

module Cloudpatrol
  module Task
    class CloudFormation
      def initialize cred
        @gate = ::AWS::CloudFormation.new(cred)
      end

      def clean_stacks allowed_age
        deleted = []
        undeleted = []
        @gate.stacks.each do |stack|
          if (Time.now - stack.creation_time).to_i > allowed_age.days
            begin
              stack.delete
              deleted << stack.inspect
            rescue AWS::Errors::Base => e
              undeleted << stack.inspect
            end
          end
        end
        return deleted, undeleted
      end
    end
  end
end
