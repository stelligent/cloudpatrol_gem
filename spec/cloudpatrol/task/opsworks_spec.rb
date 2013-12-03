require 'spec_helper'

# Know what's really hard to find online? A list of all the possible status an opsworks instance can be in
# required
# booting
# running_setup
# online
# setup_failed
# start_failed
# terminating
# terminated
# stopped
# connection_lost


describe Cloudpatrol::Task::OpsWorks do

  before(:each) do
    # create a mock OpsWorks client that returns instances, and assert the method found them
    @client = double(AWS::OpsWorks::Client)

    @ops = Cloudpatrol::Task::OpsWorks.new({ :access_key_id => '', :secret_access_key => ''})
    @ops.instance_variable_set '@gate', @client
  end

  context 'constructing with credentials' do
    #this is sort of a useless test without seeing it in action
    #it 'should use the default OpsWorks constructor if credential values are blank so that instance profiles will be in effect' do
    #  Cloudpatrol::Task::OpsWorks.new({ :access_key_id => '', :secret_access_key => ''})
    #  expect(true).should be(true)
    #end

    it 'should raise an exception if the credentials map doesnt contain the expect keys' do
      expect {
        Cloudpatrol::Task::OpsWorks.new({ :foo => ''})
      }.to raise_error('Improper AWS credentials supplied.  Map missing proper keys: {:foo=>""}')
    end
  end

  context 'does stack have instances' do
    it 'should be able to detect if a stack has running instances' do
      expect(@client).to receive(:describe_stacks)
        .with({ :stack_ids => [123] })
        .and_return ({ :stacks => [stack_json(123) ]})

      expect(@client).to receive(:describe_instances)
        .with({ :stack_id => 123 })
        .and_return ({ :instances => [ { :instance_id => 456 }, { :instance_id => 789} ]})

      actual = @ops.does_stack_have_instances? 123
      expect(actual).to be_true
    end

    it 'should be able to detect if a stack has no running instances' do
      expect(@client).to receive(:describe_stacks)
        .with({ :stack_ids => [123] })
        .and_return ({ :stacks => [stack_json(123) ]})
      expect(@client).to receive(:describe_instances)
        .with({ :stack_id => 123 })
        .and_return ({ :instances => []})

      actual = @ops.does_stack_have_instances? 123
      actual.should be_false
    end
  end

  context 'stop or delete instances in stack' do
    it 'should be able to stop all instances in a stack' do
      online_and_stopped_instances = {
        :instances => [
            { :instance_id => 456, :status => 'online' },
            { :instance_id => 789, :status => 'stopped'}
        ]
      }

      expect(@client).to receive(:describe_stacks)
        .with({ :stack_ids => [123] })
        .and_return ({ :stacks => [{ :stack_id => 123 }]})

      expect(@client).to receive(:describe_instances)
        .with({ :stack_id => 123 })
        .and_return (online_and_stopped_instances)

      expect(@client).to receive(:stop_instance)
        .with({ :instance_id => 456 })

      actual = @ops.stop_all_instances_for_stack 123
      actual.should be_true
    end

    it 'should be able to delete all instances in a stack' do
      one_online_and_one_shutdown_instance = {
          :instances => [
              { :instance_id => 456, :status => 'online' },
              { :instance_id => 789, :status => 'shutdown'}
          ]
      }

      expect(@client).to receive(:describe_stacks)
                         .with({ :stack_ids => [123]})
                         .and_return ({ :stacks => [{ :stack_id => 123 }]})

      expect(@client).to receive(:describe_instances)
                         .with({ :stack_id => 123  })
                         .and_return (one_online_and_one_shutdown_instance)

      [ { :instance_id => 456 }, { :instance_id => 789 } ].each do |instance_to_delete|
        expect(@client).to receive(:delete_instance)
                           .with(instance_to_delete)
      end

      actual = @ops.delete_all_instances_for_stack 123
      actual.should be_true
    end
  end
  context 'are_all_instances_stopped_for_stack?' do
    it 'should be able to determine if all instances in a stack are stopped' do
      two_stopped_instances = {
          :instances => [
              { :instance_id => 456, :status => 'stopped' },
              { :instance_id => 789, :status => 'stopped'}
          ]
      }

      expect(@client).to receive(:describe_stacks)
        .with({ :stack_ids => [123] })
        .and_return ({ :stacks => [{ :stack_id => 123 }]})

      expect(@client).to receive(:describe_instances)
        .with({ :stack_id => 123 })
        .and_return (two_stopped_instances)

      actual = @ops.are_all_instances_stopped_for_stack? 123
      actual.should be_true
    end

    it 'should be able to determine if any instances in a layer are running' do

      one_online_instance_and_one_stopped_instance = {
        :instances => [
            { :instance_id => 456, :status => 'online' },
            { :instance_id => 789, :status => 'stopped'}
        ]
      }

      expect(@client).to receive(:describe_stacks)
        .with({ :stack_ids => [123] })
        .and_return ({ :stacks => [{ :stack_id => 123 }]})

      expect(@client).to receive(:describe_instances)
        .with({ :stack_id => 123 })
        .and_return (one_online_instance_and_one_stopped_instance)

      actual = @ops.are_all_instances_stopped_for_stack? 123
      actual.should be_false
    end
  end

  context 'does_stack_have_layers?' do
    it 'should be able to determine if there are layers in a stack' do

      expect(@client).to receive(:describe_stacks)
        .with(no_args())
        .and_return ({ :stacks => [{ :stack_id => 123 }]})

      expect(@client).to receive(:describe_layers)
        .with({ :stack_id => 123 })
        .and_return ({ :layers => [{ :instances => [] } ]})

      actual = @ops.does_stack_have_layers? 123
      actual.should be_true
    end

    it 'should be able to determine if there are not any layers in a stack' do

      expect(@client).to receive(:describe_stacks)
        .with(no_args())
        .and_return ({ :stacks => [{ :stack_id => 123 }]})

      expect(@client).to receive(:describe_layers)
        .with({ :stack_id => 123 })
        .and_return ({ :layers => []})

      actual = @ops.does_stack_have_layers? 123
      actual.should be_false
    end
  end

  context 'clean_stacks' do
    it 'should be able to avoid deleting stacks that are in a whitelist' do

      whitelist = [ 2 ]
      allowed_age = 0

      expired_stacks = [ stack_json(1), stack_json(2), stack_json(3) ]
      expect(@client).to receive(:describe_stacks)
                         .and_return ({ :stacks => expired_stacks })

      @ops.stub(:expired) { true }
      @ops.stub(:delete_stack_and_associated_resources)

      deleted_stacks, surviving_stacks = @ops.clean_stacks allowed_age, whitelist

      expect(deleted_stacks).to eq([ stack_json(1), stack_json(3)])
      expect(surviving_stacks).to eq( [ stack_json(2) ])
    end

    it 'should deal with no specified whitelist' do
      allowed_age = 0

      expired_stacks = [ stack_json(1), stack_json(2), stack_json(3) ]
      expect(@client).to receive(:describe_stacks)
                         .and_return ({ :stacks => expired_stacks })

      @ops.stub(:expired) { true }
      @ops.stub(:delete_stack_and_associated_resources)

      deleted_stacks, surviving_stacks = @ops.clean_stacks allowed_age

      expect(deleted_stacks).to eq([ stack_json(1), stack_json(2), stack_json(3)])
      expect(surviving_stacks).to eq( [ ])
    end

    it 'should ignore all OpsWorks stacks before a certain age' do
      @ops.instance_variable_set '@sleeptime', 0

      creation_time = "#{Time.now - 3.days}"
      expected_stack = { :stack_id => 123, :created_at => creation_time}
      expect(@client).to receive(:describe_stacks)
        .with(no_args())
        .and_return({ :stacks => [expected_stack] })

      actual_successes, actual_failures = @ops.clean_stacks 4

      actual_successes.count.should == 0
      actual_failures.count.should == 0
    end

    it 'should handle errrors cleanly when deleting OpsWorks stacks' do
      @ops.instance_variable_set '@sleeptime', 0

      creation_time = "#{Time.now - 3.days}"
      expected_stack = { :stack_id => 123, :created_at => creation_time}
      expect(@client).to receive(:describe_stacks).with(no_args()).at_least(3).times.and_return({ :stacks => [expected_stack] })

      expect(@client).to receive(:describe_stacks).with({:stack_ids => [123]}).at_least(:once).and_return({ :stacks => [expected_stack] })

      expected_app = { :app_id => 987, :created_at => creation_time}
      expect(@client).to receive(:describe_apps).with({ :stack_id => 123}).and_return({:apps => [expected_app]}, {:apps => [expected_app]}, {:apps => []})
      expect(@client).to receive(:delete_app).with({:app_id => 987})

      expected_instance_online = { :instance_id => 456, :created_at => creation_time, :status => "online"}
      expected_instance_stopped = { :instance_id => 456, :created_at => creation_time, :status => "stopped"}
      expect(@client).to receive(:describe_instances).with({:stack_id => 123}).and_return(
                            {:instances => [expected_instance_online]},  # all stopped?
                            {:instances => [expected_instance_online]},  # stop
                            {:instances => [expected_instance_stopped]}, # all stoppped?
                            {:instances => [expected_instance_stopped]}, # exist?
                            {:instances => [expected_instance_stopped]}, # delete
                            {:instances => []}  )                        # exist?
      expect(@client).to receive(:stop_instance).with({ :instance_id => 456 }).exactly(:once)
      expect(@client).to receive(:delete_instance).with({ :instance_id => 456 }).exactly(:once)
      expected_layer = { :layer_id => 321, :created_at => creation_time}
      expect(@client).to receive(:describe_layers).with({:stack_id => 123}).and_return({:layers => [expected_layer]}, {:layers => [expected_layer]}, {:layers => []})
      expect(@client).to receive(:delete_layer).with({ :layer_id => 321 }).exactly(:once)
      expect(@client).to receive(:delete_stack).with({:stack_id => 123}).and_raise(AWS::Errors::Base, "Failed to delete stack.")

      actual_successes, actual_failures = @ops.clean_stacks 2

      actual_successes.count.should == 0

      actual_failures.count.should == 1
      actual_failures.first.should == expected_stack
    end

    it 'should handle errrors cleanly when deleting OpsWorks stacks' do

      @ops.instance_variable_set '@sleeptime', 0

      creation_time = "#{Time.now - 3.days}"
      expected_stack = { :stack_id => 123, :created_at => creation_time}

      expect(@client).to receive(:describe_stacks)
                         .with(no_args())
                         .and_return({ :stacks => [expected_stack] })

      expect(@client).to receive(:describe_stacks)
                         .with({:stack_ids => [123]})
                         .at_least(:once)
                         .and_return({ :stacks => [expected_stack] })

      expected_app = { :app_id => 987, :created_at => creation_time}

      expect(@client).to receive(:describe_apps)
                         .with({ :stack_id => 123})
                         .and_return({:apps => [expected_app]}, {:apps => [expected_app]})

      expect(@client).to receive(:delete_app)
                         .with({:app_id => 987})
                         .and_raise(AWS::Errors::Base, 'Failed to delete app.')

      actual_successes, actual_failures = @ops.clean_stacks 2

      actual_successes.count.should == 0

      actual_failures.count.should == 1
      actual_failures.first.should == expected_stack
    end

    it 'should delete all OpsWorks stacks after a certain age' do
      @ops.instance_variable_set '@sleeptime', 0

      creation_time = "#{Time.now - 3.days}"
      expected_stack = { :stack_id => 123, :created_at => creation_time}
      expect(@client).to receive(:describe_stacks).with(no_args()).at_least(3).times.and_return({ :stacks => [expected_stack] })

      expect(@client).to receive(:describe_stacks).with({:stack_ids => [123]}).at_least(:once).and_return({ :stacks => [expected_stack] })

      expected_app = { :app_id => 987, :created_at => creation_time}
      expect(@client).to receive(:describe_apps).with({ :stack_id => 123}).and_return({:apps => [expected_app]}, {:apps => [expected_app]}, {:apps => []})
      expect(@client).to receive(:delete_app).with({:app_id => 987})

      expected_instance_online = { :instance_id => 456, :created_at => creation_time, :status => "online"}
      expected_instance_stopped = { :instance_id => 456, :created_at => creation_time, :status => "stopped"}
      expect(@client).to receive(:describe_instances).with({:stack_id => 123}).and_return(
                             {:instances => [expected_instance_online]},  # all stopped?
                             {:instances => [expected_instance_online]},  # stop
                             {:instances => [expected_instance_stopped]}, # all stoppped?
                             {:instances => [expected_instance_stopped]}, # exist?
                             {:instances => [expected_instance_stopped]}, # delete
                             {:instances => []}  )                        # exist?
      expect(@client).to receive(:stop_instance).with({ :instance_id => 456 }).exactly(:once)
      expect(@client).to receive(:delete_instance).with({ :instance_id => 456 }).exactly(:once)
      expected_layer = { :layer_id => 321, :created_at => creation_time}
      expect(@client).to receive(:describe_layers).with({:stack_id => 123}).and_return({:layers => [expected_layer]}, {:layers => [expected_layer]}, {:layers => []})
      expect(@client).to receive(:delete_layer).with({ :layer_id => 321 }).exactly(:once)
      expect(@client).to receive(:delete_stack).with({:stack_id => 123})

      actual_successes, actual_failures = @ops.clean_stacks 2

      actual_successes.count.should == 1
      actual_successes.first.should == expected_stack

      actual_failures.count.should == 0
    end
  end

  def stack_json(id)
    { :stack_id => id }
  end

end

