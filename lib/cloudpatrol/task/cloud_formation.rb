module Cloudpatrol::Task
  class CloudFormation
    def clean_stacks allowed_age
      deleted = []
      stacks.each do |stack|
        if (Time.now - stack.creation_time).to_i > allowed_age * 24 * 60 * 60
          deleted << stack
          stack.delete
        end
      end
      deleted
    end
  end
end
