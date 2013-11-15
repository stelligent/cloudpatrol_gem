require 'securerandom'
require 'aws'

# this is going to need another table
# and the log is going to have to have a specific table
# should whitelists be by resource id? 

module Cloudpatrol
  module Task
    class DynamoDB
      def initialize cred, table_name
        @gate = dynamodb_client(cred)
        @table = @gate.tables[table_name]

        unless @table.exists?
          puts "Creating DynamoDB table \"#{table_name}\", wait a while..."
          @table = @gate.tables.create(table_name, 1, 1)
          sleep 1 while @table.status == :creating
          puts 'Table created'
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

      private

      def dynamodb_client(credentials_map)
        if not valid_credentials_map(credentials_map)
          raise "Improper AWS credentials supplied.  Map missing proper keys: #{credentials_map}"
        end

        if credentials_map[:access_key_id].strip.empty?
          ::AWS::DynamoDB.new
        else
          ::AWS::DynamoDB.new(credentials_map)
        end
      end

      def valid_credentials_map(credentials_map)
        credentials_map[:access_key_id] and credentials_map[:secret_access_key]
      end
    end
  end
end
