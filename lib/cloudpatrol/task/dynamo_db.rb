require 'securerandom'
require 'aws'

module Cloudpatrol
  module Task
    class DynamoDB
      def initialize cred
        @gate = ::AWS::DynamoDB.new(cred)
      end

      def log table_name, action, response
        return false unless table_name
        t = @gate.tables[table_name]

        # Ensuring the table exists
        unless t.exists?
          puts "Creating DynamoDB table \"#{table_name}\", wait a while..."
          t = @gate.tables.create(table_name, 1, 1)
          sleep 1 while t.status == :creating
          puts "Table created"
        end

        if t.status == :active
          i = t.items.create(id: SecureRandom.uuid, action: action.to_s, response: response.to_s, time: Time.now.to_s)
          i
        else
          nil
        end
      end
    end
  end
end
