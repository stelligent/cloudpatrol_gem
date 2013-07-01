require 'aws'

module Cloudpatrol::Task
  class IAM
    def initialize access_key_id, secret_access_key
      @gate = ::AWS::IAM.new(access_key_id: access_key_id, secret_access_key: secret_access_key)
    end

    def clean_users
      deleted = 0
      @gate.users.each do |user|
        unless user.name =~ /_/ or user.mfa_devices.count > 0
          deleted += 1
          user.delete!
        end
      end
      return deleted
    end
  end

  class EC2
    def initialize access_key_id, secret_access_key, region
      @gate = ::AWS::EC2.new(access_key_id: access_key_id, secret_access_key: secret_access_key, region: region)
    end

    def clean_security_groups
      deleted = 0
      protected_groups = []
      @gate.security_groups.each do |sg|
        sg.ip_permissions.each do |perm|
          perm.groups.each do |dependent_sg|
            protected_groups << dependent_sg
          end
        end
      end
      @gate.security_groups.each do |sg|
        if sg.exists? and !protected_groups.include?(sg) and sg.instances.count == 0
          deleted += 1
          sg.delete
        end
      end
      return deleted
    end
  end

  class OpsWorks
    def initialize access_key_id, secret_access_key
      @gate = ::AWS::OpsWorks::Client.new(access_key_id: access_key_id, secret_access_key: secret_access_key)
    end

    def clean_apps allowed_age
      deleted = 0
      @gate.describe_stacks[:stacks].each do |stack|
        @gate.describe_apps(stack_id: stack[:stack_id])[:apps].each do |app|
          if (Time.now - Time.parse(app[:created_at])).to_i > allowed_age * 24 * 60 * 60
            deleted += 1
            @gate.delete_app app_id: app[:app_id]
          end
        end
      end
      return deleted
    end

    def clean_instances allowed_age
      deleted = 0
      @gate.describe_stacks[:stacks].each do |stack|
        @gate.describe_instances(stack_id: stack[:stack_id])[:instances].each do |instance|
          if (Time.now - Time.parse(instance[:created_at])).to_i > allowed_age * 24 * 60 * 60
            deleted += 1
            @gate.delete_instance instance_id: instance[:instance_id]
          end
        end
      end
      return deleted
    end

    def clean_layers allowed_age
      deleted = 0
      @gate.describe_stacks[:stacks].each do |stack|
        @gate.describe_layers(stack_id: stack[:stack_id])[:layers].each do |layer|
          if (Time.now - Time.parse(layer[:created_at])).to_i > allowed_age * 24 * 60 * 60
            deleted += 1
            @gate.delete_layer layer_id: layer[:layer_id]
          end
        end
      end
      return deleted
    end

    def clean_stacks allowed_age
      deleted = 0
      @gate.describe_stacks[:stacks].each do |stack|
        if (Time.now - Time.parse(stack[:created_at])).to_i > allowed_age * 24 * 60 * 60
          deleted += 1
          @gate.delete_stack stack_id: stack[:stack_id]
        end
      end
      return deleted
    end
  end

  class CloudFormation
    def initialize access_key_id, secret_access_key
      @gate = ::AWS::CloudFormation.new(access_key_id: access_key_id, secret_access_key: secret_access_key)
    end

    def clean_stacks allowed_age
      deleted = 0
      @gate.stacks.each do |stack|
        if (Time.now - stack.creation_time).to_i > allowed_age * 24 * 60 * 60
          deleted += 1
          stack.delete
        end
      end
      return deleted
    end
  end

  # def self.delete_ec2_instances
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
