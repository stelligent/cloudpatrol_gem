module Cloudpatrol::Task
  class OpsWorks
    def clean_apps allowed_age
      deleted = []
      describe_stacks[:stacks].each do |stack|
        describe_apps(stack_id: stack[:stack_id])[:apps].each do |app|
          if (Time.now - Time.parse(app[:created_at])).to_i > allowed_age.days
            deleted << app
            delete_app app_id: app[:app_id]
          end
        end
      end
      deleted
    end

    def clean_instances allowed_age
      deleted = []
      describe_stacks[:stacks].each do |stack|
        describe_instances(stack_id: stack[:stack_id])[:instances].each do |instance|
          if (Time.now - Time.parse(instance[:created_at])).to_i > allowed_age.days
            deleted << instance
            delete_instance instance_id: instance[:instance_id]
          end
        end
      end
      deleted
    end

    def clean_layers allowed_age
      deleted = []
      describe_stacks[:stacks].each do |stack|
        describe_layers(stack_id: stack[:stack_id])[:layers].each do |layer|
          if (Time.now - Time.parse(layer[:created_at])).to_i > allowed_age.days
            deleted << layer
            delete_layer layer_id: layer[:layer_id]
          end
        end
      end
      deleted
    end

    def clean_stacks allowed_age
      deleted = []
      describe_stacks[:stacks].each do |stack|
        if (Time.now - Time.parse(stack[:created_at])).to_i > allowed_age.days
          deleted << stack
          delete_stack stack_id: stack[:stack_id]
        end
      end
      deleted
    end
  end
end
