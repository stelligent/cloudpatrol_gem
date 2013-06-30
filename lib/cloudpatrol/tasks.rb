module Cloudpatrol
  module Tasks
    module EC2
    end

    class IAM
      def initialize
        @gate = ::AWS.iam(access_key_id: $access_key_id, secret_access_key: $secret_access_key)
      end

      def clean_users
        deleted = 0
        @gate.users.each do |user|
          unless user.name =~ /_/ or user.mfa_devices.count > 0
            deleted += 1
            user.delete
          end
        end
        return deleted
      end
    end

    module CF
      GATE = ::AWS::CloudFormation.new
    end

    module OW
      GATE = ::AWS::OpsWorks.new.client
    end

    # def self.delete_expired_keypairs
    # end

    # def self.delete_ec2_instances
    # end

    # def self.delete_cloudformation_stacks
    #   puts "Deleting CloudFormation stacks older than #{TODO}"
    #   deleted = []
    #   @@cf.stacks.each do |stack|
    #     if (Time.now - stack.creation_time) > TODO.days
    #       deleted << stack.name
    #       stack.delete
    #     end
    #   end
    #   puts if deleted.size > 0
    #     "Finished. Deleted stacks: #{deleted.join(", ")}"
    #   else
    #     "Finished. No stacks deleted."
    #   end
    # end

    # def self.delete_opsworks_apps
    #   # pending
    # end

    # def self.delete_opsworks_instances
    #   # pending
    # end

    # def self.delete_opsworks_layers
    #   # pending
    # end

    # def self.delete_opsworks_stacks
    #   # pending
    # end

    # def self.stop_ec2_instances
    #   @@ec2.instances.each do |instance|
    #     instance.stop
    #   end
    # end

    # def self.start_ec2_instances
    #   @@ec2.instances.each do |instance|
    #     instance.start
    #   end
    # end

    # def self.delete_ports_assigned_to_default
    #   # pending
    # end
  end
end
