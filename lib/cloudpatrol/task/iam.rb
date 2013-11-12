require 'aws'

module Cloudpatrol
  module Task
    class IAM

      def initialize cred
        @gate = ::AWS::IAM.new(cred)
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

    end
  end
end
