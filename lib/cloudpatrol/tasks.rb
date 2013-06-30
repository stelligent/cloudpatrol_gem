class Cloudpatrol::Tasks
  TODO = 5 # fetch from db (later)

  # TODO: Make separate modules for different

  @@ec2 = AWS.ec2
  @@iam = AWS.iam
  @@cf  = AWS::CloudFormation.new
  @@ow  = AWS::OpsWorks.new.client

  def self.delete_iam_users_without_mfa
    puts "Deleting IAM users without MFA"
    deleted = []
    @@iam.users.each do |user|
      unless user.name =~ /_/ or user.mfa_devices.count > 0
        deleted << user.name
        user.delete
      end
    end
    puts if deleted.size > 0
      "Finished. Deleted users: #{deleted.join(", ")}"
    else
      "Finished. No users deleted."
    end
  end

  # def self.delete_expired_keypairs
  # end

  # def self.delete_ec2_instances
  # end

  def self.delete_cloudformation_stacks
    puts "Deleting CloudFormation stacks older than #{TODO}"
    deleted = []
    @@cf.stacks.each do |stack|
      if (Time.now - stack.creation_time) > TODO.days
        deleted << stack.name
        stack.delete
      end
    end
    puts if deleted.size > 0
      "Finished. Deleted stacks: #{deleted.join(", ")}"
    else
      "Finished. No stacks deleted."
    end
  end

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

  def self.stop_ec2_instances
    @@ec2.instances.each do |instance|
      instance.stop
    end
  end

  def self.start_ec2_instances
    @@ec2.instances.each do |instance|
      instance.start
    end
  end

  def self.delete_ports_assigned_to_default
    # pending
  end
end
