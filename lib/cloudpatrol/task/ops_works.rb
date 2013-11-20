require 'aws-sdk'


module Cloudpatrol
  module Task
    class OpsWorks
      def initialize(cred)
        @gate = opsworks_client(cred)
        @sleeptime = 10
      end

      def clean_stacks(allowed_age, whitelist=nil)
        deleted = []
        undeleted = []
        @gate.describe_stacks[:stacks].each do |stack|
          if expired(stack[:created_at], allowed_age)
            begin
              if whitelisted(stack[:stack_id], whitelist)
                undeleted << stack
              else
                delete_stack_and_associated_resources(stack[:stack_id])
                deleted << stack
              end
            rescue
              undeleted << stack
            end
          end
        end
        return deleted, undeleted
      end

      def delete_stack_and_associated_resources stack_id
        while (does_stack_have_apps? stack_id)
          delete_all_apps_for_stack stack_id
          sleep @sleeptime
        end
        while (!are_all_instances_stopped_for_stack? stack_id)
          stop_all_instances_for_stack stack_id
          sleep @sleeptime
        end
        while (does_stack_have_instances? stack_id)
          delete_all_instances_for_stack stack_id
          sleep @sleeptime
        end
        while(does_stack_have_layers? stack_id)
          delete_all_layers_for_stack stack_id
          sleep @sleeptime
        end
        
        @gate.delete_stack stack_id: stack_id
      end 

      def stop_all_instances_for_stack stack_id
        @gate.describe_stacks({:stack_ids => [stack_id]})[:stacks].each do |stack|
          @gate.describe_instances(stack_id: stack[:stack_id])[:instances].each do |instance|
            if (instance[:status] != "stopped")
              @gate.stop_instance instance_id: instance[:instance_id]
            end
          end
        end
      end

      def are_all_instances_stopped_for_stack? stack_id
        result = true
        @gate.describe_stacks({:stack_ids => [stack_id]})[:stacks].each do |stack|
          @gate.describe_instances(stack_id: stack[:stack_id])[:instances].each do |instance|
            if (instance[:status] != "stopped")
              result = false
              break
            end
          end
        end
        return result
      end

      def does_stack_have_instances? stack_id
        result = false
        @gate.describe_stacks({:stack_ids => [stack_id]})[:stacks].each do |stack|
          @gate.describe_instances(stack_id: stack[:stack_id])[:instances].each do |instance|
            result = true
            break
          end
        end
        return result
      end

      def does_stack_have_apps? stack_id
        result = false
        @gate.describe_stacks({:stack_ids => [stack_id]})[:stacks].each do |stack|
          @gate.describe_apps(stack_id: stack[:stack_id])[:apps].each do |app|
            result = true
            break
          end
        end
        return result
      end


      def delete_all_apps_for_stack stack_id
        result = []
        @gate.describe_stacks({:stack_ids => [stack_id]})[:stacks].each do |stack|
          @gate.describe_apps(stack_id: stack[:stack_id])[:apps].each do |app|
            result << app
            @gate.delete_app app_id: app[:app_id]
          end
        end
        return result
      end

      def delete_all_instances_for_stack stack_id
        result = []
        @gate.describe_stacks({:stack_ids => [stack_id]})[:stacks].each do |stack|
          @gate.describe_instances(stack_id: stack[:stack_id])[:instances].each do |instance|

            @gate.delete_instance instance_id: instance[:instance_id]
            result << instance
          end
        end
        return result
      end

      def delete_all_layers_for_stack stack_id
        result = []
        @gate.describe_stacks({:stack_ids => [stack_id]})[:stacks].each do |stack|
          @gate.describe_layers(stack_id: stack[:stack_id])[:layers].each do |layer|
            @gate.delete_layer layer_id: layer[:layer_id]
            result << layer
          end
        end
        return result
      end

      def does_stack_have_layers? stack_id
        result = false
        @gate.describe_stacks[:stacks].each do |stack| 
          @gate.describe_layers(stack_id: stack_id)[:layers].each do |layer|
            result = true
            break
          end
        end
        return result        
      end    

      private

      def whitelisted(stack_id, whitelist)
        if whitelist.nil?
          false
        else
          whitelist.include? stack_id
        end
      end

      def opsworks_client(credentials_map)
        unless valid_credentials_map(credentials_map)
          raise "Improper AWS credentials supplied.  Map missing proper keys: #{credentials_map}"
        end

        if credentials_map[:access_key_id].strip.empty?
          ::AWS::OpsWorks::Client.new
        else
          ::AWS::OpsWorks::Client.new(credentials_map)
        end
      end

      def valid_credentials_map(credentials_map)
        credentials_map[:access_key_id] and credentials_map[:secret_access_key]
      end

      def expired(time_string, allowed_age)
        (Time.now - Time.parse(time_string)).to_i > allowed_age.days
      end

    end
  end
end
