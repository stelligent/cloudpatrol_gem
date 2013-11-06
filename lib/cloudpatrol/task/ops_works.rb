require 'aws'


module Cloudpatrol
  module Task
    class OpsWorks
      def initialize cred
        @gate = ::AWS::OpsWorks::Client.new(cred)
        @sleeptime = 10
      end

      def clean_apps allowed_age
        deleted = []
        @gate.describe_stacks[:stacks].each do |stack|
          @gate.describe_apps(stack_id: stack[:stack_id])[:apps].each do |app|
            if (Time.now - Time.parse(app[:created_at])).to_i > allowed_age.days
              deleted << app
              @gate.delete_app app_id: app[:app_id]
            end
          end
        end
        deleted
      end

      def clean_instances allowed_age
        deleted = []
        @gate.describe_stacks[:stacks].each do |stack|
          @gate.describe_instances(stack_id: stack[:stack_id])[:instances].each do |instance|
            if (Time.now - Time.parse(instance[:created_at])).to_i > allowed_age.days
              deleted << instance
              @gate.delete_instance instance_id: instance[:instance_id]
            end
          end
        end
        deleted
      end

      def clean_layers allowed_age
        deleted = []
        @gate.describe_stacks[:stacks].each do |stack|
          @gate.describe_layers(stack_id: stack[:stack_id])[:layers].each do |layer|
            if (Time.now - Time.parse(layer[:created_at])).to_i > allowed_age.days
              deleted << layer
              @gate.delete_layer layer_id: layer[:layer_id]
            end
          end
        end
        deleted
      end

      def clean_stacks allowed_age
        deleted = []
        @gate.describe_stacks[:stacks].each do |stack|
          if (Time.now - Time.parse(stack[:created_at])).to_i > allowed_age.days
            deleted << stack
            delete_stack_and_associated_resources stack_id: stack[:stack_id]
          end
        end
        deleted
      end

      def delete_stack_and_associated_resources stack_id
        puts "are their running instances?"
        while (does_stack_have_apps? stack_id)
          puts "> delete the apps"
          delete_all_apps_for_stack stack_id
          sleep @sleeptime
        end
        while (!are_all_instances_stopped_for_stack? stack_id)
          puts "> stop the instances"
          stop_all_instances_for_stack stack_id
          sleep @sleeptime
        end
        puts "are there any instances?"
        while (does_stack_have_instances? stack_id)
          puts "> delete the instances"
          delete_all_instances_for_stack stack_id
          sleep @sleeptime
        end
        puts "does the stack have layers?"
        while(does_stack_have_layers? stack_id)
          puts "> delete the layers"
          delete_all_layers_for_stack stack_id
          sleep @sleeptime
        end
        puts "delete the stack"
        @gate.delete_stack stack_id: stack_id
      end 
    
      # does layer have instances?
      def does_layer_have_instances? layer_id
        result = false
        @gate.describe_stacks[:stacks].each do |stack|
          @gate.describe_layers(stack_id: stack[:stack_id])[:layers].each do |layer|
            @gate.describe_instances(layer_id: layer[:layer_id])[:instances].each do |instance|
              result = true
              break
            end
          end
        end
        return result
      end

      def does_stack_have_instances? stack_id
        result = false
        @gate.describe_stacks({:stack_ids => [stack_id]})[:stacks].each do |stack|
          @gate.describe_layers(stack_id: stack[:stack_id])[:layers].each do |layer|
            @gate.describe_instances(layer_id: layer[:layer_id])[:instances].each do |instance|
              result = true
              break
            end
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

      def stop_all_instances_for_stack stack_id
        result = []
        @gate.describe_stacks({:stack_ids => [stack_id]})[:stacks].each do |stack|
          @gate.describe_layers(stack_id: stack[:stack_id])[:layers].each do |layer|
            @gate.describe_instances(layer_id: layer[:layer_id])[:instances].each do |instance|
              puts instance[:hostname]
              if (instance[:status] != "stopped")
                @gate.stop_instance instance_id: instance[:instance_id]
                result << instance
              end
            end
          end
        end
        return result
      end

      def are_all_instances_stopped_for_layer? layer_id
        result = true
        @gate.describe_stacks[:stacks].each do |stack|
          @gate.describe_layers(stack_id: stack[:stack_id])[:layers].each do |layer|
            @gate.describe_instances(layer_id: layer[:layer_id])[:instances].each do |instance|
            puts instance[:hostname]
              if (instance[:status] != "stopped")
                result = false
                break
              end
            end
          end
        end
        return result
      end

      def are_all_instances_stopped_for_stack? stack_id
        result = true
        @gate.describe_stacks({:stack_ids => [stack_id]})[:stacks].each do |stack|
          @gate.describe_layers(stack_id: stack[:stack_id])[:layers].each do |layer|
            @gate.describe_instances(layer_id: layer[:layer_id])[:instances].each do |instance|
            puts instance[:hostname]
              if (instance[:status] != "stopped")
                result = false
                break
              end
            end
          end
        end
        return result
      end

      def delete_all_instances_for_layer layer_id
        result = []
        @gate.describe_stacks[:stacks].each do |stack|
          @gate.describe_layers(stack_id: stack[:stack_id])[:layers].each do |layer|
            @gate.describe_instances(layer_id: layer[:layer_id])[:instances].each do |instance|
              puts instance[:hostname]
              @gate.delete_instance instance_id: instance[:instance_id]
              result << instance
            end
          end
        end
        return result
      end

      def delete_all_instances_for_stack stack_id
        result = []
        @gate.describe_stacks({:stack_ids => [stack_id]})[:stacks].each do |stack|
          @gate.describe_layers(stack_id: stack[:stack_id])[:layers].each do |layer|
            @gate.describe_instances(layer_id: layer[:layer_id])[:instances].each do |instance|
              puts instance[:hostname]
              @gate.delete_instance instance_id: instance[:instance_id]
              result << instance
            end
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

      # unless stack is empty
      #   for each layer
      #     for each instance
      #       stop instance
      #       wait for instances to stop
      #       delete each instances
      #       wait for instances to delete
      #     delete layer
      #     wait for layer to delete
      # delete stack

    end
  end
end
