module Cloudpatrol::Task
  class IAM
    def clean_users
      deleted = []
      users.each do |user|
        unless user.name =~ /^_/ or user.mfa_devices.count > 0
          deleted << user
          user.delete!
        end
      end
      deleted
    end
  end
end
