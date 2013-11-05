require 'aws'

module Cloudpatrol
  module Task
    class OpsWorks
      def initialize cred
        @gate = ::AWS::OpsWorks::Client.new(cred)
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
            @gate.delete_stack stack_id: stack[:stack_id]
          end
        end
        deleted
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

      def stop_all_instances_for_layer layer_id
        result = []
        @gate.describe_stacks[:stacks].each do |stack|
          @gate.describe_layers(stack_id: stack[:stack_id])[:layers].each do |layer|
            @gate.describe_instances(layer_id: layer[:layer_id])[:instances].each do |instance|
              if (instance[:status] == "running")
                @gate.stop_instance instance_id: instance[:instance_id]
                result << instance
              end
            end
          end
        end
        return result
      end


      # stop all instances for layer
      # are all instances stopped for layer
      # delete all instances for layer
      # delete all layers for stack
      # does stack have layers?
      # delete all stacks

    end
  end
end
