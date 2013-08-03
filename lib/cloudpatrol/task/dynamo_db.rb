require 'securerandom'
require 'aws'

module Cloudpatrol
  module Task
    class DynamoDB
      def initialize cred, table_name
        @gate = ::AWS::DynamoDB.new(cred)
        @table = @gate.tables[table_name]

        unless @table.exists?
          puts "Creating DynamoDB table \"#{table_name}\", wait a while..."
          @table = @gate.tables.create(table_name, 1, 1)
          sleep 1 while @table.status == :creating
          puts "Table created"
        end
      rescue
        @table = nil
      end

      def log action, response
        raise unless @table

        if @table.status == :active
          item = @table.items.create(
            id: SecureRandom.uuid,
            action: action.to_s,
            response: response.to_s,
            time: Time.now.to_s
            )
        else
          nil
        end
      rescue
        false
      end
    end
  end
end
