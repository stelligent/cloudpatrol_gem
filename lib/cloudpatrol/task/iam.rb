module Cloudpatrol
  module Task
    class IAM
      def initialize cred
        @gate = ::AWS::IAM.new(cred)
      end

      def clean_users
        deleted = []
        @gate.users.each do |user|
          unless user.name =~ /^_/ or user.mfa_devices.count > 0
            deleted << user
            user.delete!
          end
        end
        deleted
      end
    end
  end
end
