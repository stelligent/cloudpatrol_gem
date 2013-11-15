require 'aws'

module Cloudpatrol
  module Task
    class IAM

      def initialize cred
        @gate = iam_client(cred)
      end

      def clean_users
        deleted = []
        undeleted = []
        users = @gate.users
        users.each do |user|
          unless user.name =~ /^_/ or user.mfa_devices.count > 0
            begin
              user.delete!
              deleted << user.inspect
            rescue AWS::Errors::Base => e
              undeleted << user.inspect
            end
          end
        end
        return deleted, undeleted
      end

      private

      def iam_client(credentials_map)
        if not valid_credentials_map(credentials_map)
          raise "Improper AWS credentials supplied.  Map missing proper keys: #{credentials_map}"
        end

        if credentials_map[:access_key_id].strip.empty?
          ::AWS::IAM.new
        else
          ::AWS::IAM.new(credentials_map)
        end
      end

      def valid_credentials_map(credentials_map)
        credentials_map[:access_key_id] and credentials_map[:secret_access_key]
      end
    end
  end
end
