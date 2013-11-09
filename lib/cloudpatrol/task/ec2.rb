require 'aws'

module Cloudpatrol
  module Task
    class EC2
      def initialize cred
        @gate = ::AWS::EC2.new(cred)
      end

      def start_instances
        started = []
        unstarted = []
        @gate.instances.each do |instance|
          begin
            instance.start
            started << instance.inspect
          rescue AWS::Errors::Base => e
            unstarted << instance.inspect
          end
        end
        return started, unstarted
      end

      def stop_instances allowed_age = 0
        stopped = []
        unstopped = []
        @gate.instances.each do |instance|
          if instance.status == :pending or instance.status == :running
            begin
              instance.stop
              stopped << instance.inspect
            rescue AWS::Errors::Base => e
              unstopped << instance.inspect
            end
          end
        end
        return stopped, unstopped
      end

      def clean_instances allowed_age
        deleted = []
        undeleted = []
        @gate.instances.each do |instance|
          if (Time.now - instance.launch_time).to_i > allowed_age.days and instance.status != :terminated
            begin
              instance.delete
              deleted << instance.inspect
            rescue AWS::Errors::Base => e
              undeleted << instance.inspect              
            end
          end
        end
        return deleted, undeleted
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
        undeleted = []
        @gate.security_groups.filter("group-name", "default").each do |sg|
          sg.ingress_ip_permissions.each do |perm|
            begin
              perm.revoke
              deleted << { port_range: perm.port_range }
            rescue
              undeleted << { port_range: perm.port_range }
            end
          end
        end
        return deleted, undeleted
      end

      def clean_elastic_ips
        deleted = []
        undeleted = []
        @gate.elastic_ips.each do |ip|
          unless ip.instance
            begin
              ip.release
              deleted << ip.inspect
            rescue AWS::Errors::Base => e
              undeleted << ip.inspect
            end
          end
        end
        return deleted, undeleted
      end


    end
  end
end
