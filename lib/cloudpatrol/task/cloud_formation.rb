require 'aws'

module Cloudpatrol
  module Task
    class CloudFormation
      def initialize cred
        @gate = cloudformation_client(cred)
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


      private

      def cloudformation_client(credentials_map)
        if not valid_credentials_map(credentials_map)
          raise "Improper AWS credentials supplied.  Map missing proper keys: #{credentials_map}"
        end

        if credentials_map[:access_key_id].strip.empty?
          ::AWS::CloudFormation.new
        else
          ::AWS::CloudFormation.new(credentials_map)
        end
      end

      def valid_credentials_map(credentials_map)
        credentials_map[:access_key_id] and credentials_map[:secret_access_key]
      end
    end
  end
end
