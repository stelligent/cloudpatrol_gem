require 'aws'

module Cloudpatrol
  module Task
    class EC2
      def initialize cred
        @gate = ec2_client(cred)
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

      def stop_instances
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
              instance.api_termination_disabled=false
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
        undeleted = []
        protected_groups = []
        # if a security group is used by another security group, we shouldn't delete it, so find all those first
        @gate.security_groups.each do |sg|
          sg.ip_permissions.each do |perm|
            perm.groups.each do |dependent_sg|
              protected_groups << dependent_sg
            end
          end
        end

        @gate.security_groups.each do |sg|
          if !protected_groups.include?(sg) and sg.exists? and sg.instances.count == 0 and sg.name != "default"
            begin
              sg.delete
              deleted << sg.inspect
            rescue AWS::Errors::Base => e
              undeleted << sg.inspect
            end
          end
        end
        return deleted, undeleted
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

      private

      def ec2_client(credentials_map)
        if not valid_credentials_map(credentials_map)
          raise "Improper AWS credentials supplied.  Map missing proper keys: #{credentials_map}"
        end

        if credentials_map[:access_key_id].strip.empty?
          ::AWS::EC2.new
        else
          ::AWS::EC2.new(credentials_map)
        end
      end

      def valid_credentials_map(credentials_map)
        credentials_map[:access_key_id] and credentials_map[:secret_access_key]
      end
    end
  end
end
