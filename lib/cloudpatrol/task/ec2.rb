module Cloudpatrol::Task
  class EC2
    def start_instances
      result = []
      instances.each do |instance|
        result << instance
        instance.start
      end
      result
    end

    def stop_instances
      result = []
      instances.each do |instance|
        result << instance
        instance.stop
      end
      result
    end

    def clean_instances allowed_age
      deleted = []
      instances.each do |instance|
        if (Time.now - instance.launch_time).to_i > allowed_age.days and instance.status != :terminated
          deleted << instance
          instance.delete
        end
      end
      deleted
    end

    def clean_security_groups
      deleted = []
      protected_groups = []
      security_groups.each do |sg|
        sg.ip_permissions.each do |perm|
          perm.groups.each do |dependent_sg|
            protected_groups << dependent_sg
          end
        end
      end
      security_groups.each do |sg|
        if sg.exists? and !protected_groups.include?(sg) and sg.instances.count == 0
          deleted << sg
          sg.delete
        end
      end
      deleted
    end

    def release_elastic_ip
      elastic_ips.create
    end

    # def delete_ports_assigned_to_default
    #   # pending
    # end
  end
end
