require 'aws-sdk'


module Cloudpatrol
  module Task
    class OpsWorks
      def initialize cred
        @gate = opsworks_client(cred)
        @sleeptime = 10
      end

      def clean_apps allowed_age
        deleted = []
        undeleted = []
        @gate.describe_stacks[:stacks].each do |stack|
          @gate.describe_apps(stack_id: stack[:stack_id])[:apps].each do |app|
            if (Time.now - Time.parse(app[:created_at])).to_i > allowed_age.days
              begin
                @gate.delete_app app_id: app[:app_id]
                deleted << app
              rescue AWS::Errors::Base => e
                undeleted << app
              end
            end
          end
        end
        return deleted, undeleted
      end

      def clean_instances allowed_age
        deleted = []
        undeleted = []
        @gate.describe_stacks[:stacks].each do |stack|
          @gate.describe_instances(stack_id: stack[:stack_id])[:instances].each do |instance|
            if (Time.now - Time.parse(instance[:created_at])).to_i > allowed_age.days
              begin
                @gate.delete_instance instance_id: instance[:instance_id]
                deleted << instance
              rescue
                undeleted << instance
              end
            end
          end
        end
        return deleted, undeleted
      end

      def clean_layers allowed_age
        deleted = []
        undeleted = []
        @gate.describe_stacks[:stacks].each do |stack|
          @gate.describe_layers(stack_id: stack[:stack_id])[:layers].each do |layer|
            if (Time.now - Time.parse(layer[:created_at])).to_i > allowed_age.days
              begin
                @gate.delete_layer layer_id: layer[:layer_id]
                deleted << layer
              rescue AWS::Errors::Base => e
                undeleted << layer
              end
            end
          end
        end
        return deleted, undeleted
      end

      def clean_stacks allowed_age
        deleted = []
        undeleted = []
        @gate.describe_stacks[:stacks].each do |stack|
          if (Time.now - Time.parse(stack[:created_at])).to_i > allowed_age.days
            begin
              delete_stack_and_associated_resources(stack[:stack_id])
              deleted << stack
            rescue AWS::Errors::Base => e
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

      def opsworks_client(credentials_map)
        if not valid_credentials_map(credentials_map)
          raise "Improper AWS credentials supplied.  Map missing proper keys: #{credentials_map}"
        end

        if not credentials_map[:access_key_id].strip.empty?
          ::AWS::OpsWorks::Client.new
        else
          ::AWS::OpsWorks::Client.new(credentials_map)
        end
      end

      def valid_credentials_map(credentials_map)
        credentials_map[:access_key_id] and credentials_map[:secret_access_key]
      end

    end
  end
end
