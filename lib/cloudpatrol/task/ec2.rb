require 'aws'

module Cloudpatrol
  module Task
    class EC2
      def initialize cred
        @gate = ::AWS::EC2.new(cred)
      end

      def start_instances
        result = []
        @gate.instances.each do |instance|
          result << instance.inspect
          instance.start
        end
        result
      end

      def stop_instances
        result = []
        @gate.instances.each do |instance|
          result << instance.inspect
          instance.stop
        end
        result
      end

      def clean_instances allowed_age
        deleted = []
        @gate.instances.each do |instance|
          if (Time.now - instance.launch_time).to_i > allowed_age.days and instance.status != :terminated
            deleted << instance.inspect
            instance.delete
          end
        end
        deleted
      end

      def clean_security_groups
        deleted = []
        protected_groups = []
        @gate.security_groups.each do |sg|
          sg.ip_permissions.each do |perm|
            perm.groups.each do |dependent_sg|
              protected_groups << dependent_sg
            end
          end
        end
        @gate.security_groups.each do |sg|
          if !protected_groups.include?(sg) and sg.exists? and sg.instances.count == 0 and sg.name != "default"
            deleted << sg.inspect
            sg.delete
          end
        end
        deleted
      end

      def clean_ports_in_default
        deleted = []
        @gate.security_groups.filter("group-name", "default").each do |sg|
          sg.ingress_ip_permissions.each do |perm|
            deleted << { port_range: perm.port_range }
            perm.revoke
          end
        end
        deleted
      end

      def clean_elastic_ips
        deleted = []
        @gate.elastic_ips.each do |ip|
          unless ip.instance
            deleted << ip.inspect
            ip.release
          end
        end
        deleted
      end
    end
  end
end
