require 'aws'

module Cloudpatrol
  module Task
    class IAM
      def initialize cred
        @gate = ::AWS::IAM.new(cred)
      end

      def clean_users
        deleted = []
        users = @gate.users
        users.each do |user|
          unless user.name =~ /^_/ or user.mfa_devices.count > 0
            begin
              user.delete!
              deleted << user.inspect
            rescue AWS::Errors::Base => e
              puts "Failed to delete #{user.name} because of #{e}"
            end
          end
        end
        deleted
      end
    end
  end
end
