require 'spec_helper'
require 'cloudpatrol'

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

 # it 'should be able to avoid deleting stacks that are in a whitelist' do

 # end

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

  it 'should be able to detect if a stack has running instances' do
    # create a mock OpsWorks client that returns instances, and assert the method found them
    client = double(AWS::OpsWorks::Client)

    ops = Cloudpatrol::Task::OpsWorks.new({ :access_key_id => '', :secret_access_key => ''})
    ops.instance_variable_set '@gate', client

    expect(client).to receive(:describe_stacks).with({ :stack_ids => [123] }).and_return ({ :stacks => [{ :stack_id => 123 }]})
    expect(client).to receive(:describe_instances).with({ :stack_id => 123 }).and_return ({ :instances => [ { :instance_id => 456 }, { :instance_id => 789} ]})

    actual = ops.does_stack_have_instances? 123
    actual.should be_true
  end

  it "should be able to detect if a stack has no running instances" do 
    # create a mock OpsWorks client that returns no instances, and assert the method found none
    client = double(AWS::OpsWorks::Client)

    ops = Cloudpatrol::Task::OpsWorks.new({ :access_key_id => '', :secret_access_key => ''})
    ops.instance_variable_set '@gate', client

    expect(client).to receive(:describe_stacks).with({ :stack_ids => [123] }).and_return ({ :stacks => [{ :stack_id => 123 }]})
    expect(client).to receive(:describe_instances).with({ :stack_id => 123 }).and_return ({ :instances => []})

    actual = ops.does_stack_have_instances? 123
    actual.should be_false
  end

  it "should be able to stop all instances in a stack" do
    # create a mock OpsWorks client that returns instances, and assert the method found them
    client = double(AWS::OpsWorks::Client)

    ops = Cloudpatrol::Task::OpsWorks.new({ :access_key_id => '', :secret_access_key => ''})
    ops.instance_variable_set '@gate', client

    expect(client).to receive(:describe_stacks).with({ :stack_ids => [123] }).and_return ({ :stacks => [{ :stack_id => 123 }]})
    expect(client).to receive(:describe_instances).with({ :stack_id => 123 }).and_return ({ :instances => [ { :instance_id => 456, :status => "online" }, { :instance_id => 789, :status => "stopped"} ]})
    expect(client).to receive(:stop_instance).with({ :instance_id => 456 })

    actual = ops.stop_all_instances_for_stack 123
    actual.should be_true
  end 

  it "should be able to determine if all instances in a stack are stopped" do
    # create a mock OpsWorks client that returns instances, and assert the method found them
    client = double(AWS::OpsWorks::Client)

    ops = Cloudpatrol::Task::OpsWorks.new({ :access_key_id => '', :secret_access_key => ''})
    ops.instance_variable_set '@gate', client

    expect(client).to receive(:describe_stacks).with({ :stack_ids => [123] }).and_return ({ :stacks => [{ :stack_id => 123 }]})
    expect(client).to receive(:describe_instances).with({ :stack_id => 123 }).and_return ({ :instances => [ { :instance_id => 456, :status => "stopped" }, { :instance_id => 789, :status => "stopped"} ]})

    actual = ops.are_all_instances_stopped_for_stack? 123
    actual.should be_true
  end 

  it "should be able to determine if any instances in a layer are running" do
    # create a mock OpsWorks client that returns instances, and assert the method found them
    client = double(AWS::OpsWorks::Client)

    ops = Cloudpatrol::Task::OpsWorks.new({ :access_key_id => '', :secret_access_key => ''})
    ops.instance_variable_set '@gate', client

    expect(client).to receive(:describe_stacks).with({ :stack_ids => [123] }).and_return ({ :stacks => [{ :stack_id => 123 }]})
    expect(client).to receive(:describe_instances).with({ :stack_id => 123 }).and_return ({ :instances => [ { :instance_id => 456, :status => "online" }, { :instance_id => 789, :status => "stopped"} ]})

    actual = ops.are_all_instances_stopped_for_stack? 123
    actual.should be_false
  end 

  it "should be able to delete all instances in a stack" do
    # create a mock OpsWorks client that returns instances, and assert the method found them
    client = double(AWS::OpsWorks::Client)

    ops = Cloudpatrol::Task::OpsWorks.new({ :access_key_id => '', :secret_access_key => ''})
    ops.instance_variable_set '@gate', client

    expect(client).to receive(:describe_stacks).with({ :stack_ids => [123]}).and_return ({ :stacks => [{ :stack_id => 123 }]})
    expect(client).to receive(:describe_instances).with({ :stack_id => 123  }).and_return ({ :instances => [ { :instance_id => 456, :status => "online" }, { :instance_id => 789, :status => "shutdown"} ]})
    expect(client).to receive(:delete_instance).with({ :instance_id => 456 } )
    expect(client).to receive(:delete_instance).with({ :instance_id => 789 } )

    actual = ops.delete_all_instances_for_stack 123
    actual.should be_true
  end 


  it "should be able to determine if there are layers in a stack" do
    # create a mock OpsWorks client that returns instances, and assert the method found them
    client = double(AWS::OpsWorks::Client)

    ops = Cloudpatrol::Task::OpsWorks.new({ :access_key_id => '', :secret_access_key => ''})
    ops.instance_variable_set '@gate', client

    expect(client).to receive(:describe_stacks).with(no_args()).and_return ({ :stacks => [{ :stack_id => 123 }]})
    expect(client).to receive(:describe_layers).with({ :stack_id => 123 }).and_return ({ :layers => [{ :instances => [] } ]})
  
    actual = ops.does_stack_have_layers? 123
    actual.should be_true
  end 

  it "should be able to determine if there are not any layers in a stack" do
    # create a mock OpsWorks client that returns instances, and assert the method found them
    client = double(AWS::OpsWorks::Client)

    ops = Cloudpatrol::Task::OpsWorks.new({ :access_key_id => '', :secret_access_key => ''})
    ops.instance_variable_set '@gate', client

    expect(client).to receive(:describe_stacks).with(no_args()).and_return ({ :stacks => [{ :stack_id => 123 }]})
    expect(client).to receive(:describe_layers).with({ :stack_id => 123 }).and_return ({ :layers => []})
  
    actual = ops.does_stack_have_layers? 123
    actual.should be_false
  end 

  it "should clean all existing OpsWorks apps after a certain age" do
    client = double(AWS::OpsWorks::Client)

    ops = Cloudpatrol::Task::OpsWorks.new({ :access_key_id => '', :secret_access_key => ''})
    ops.instance_variable_set '@gate', client

    expect(client).to receive(:describe_stacks).with(no_args()).and_return({ :stacks => [{ :stack_id => 123 }] })
    creation_time = "#{Time.now - 3.days}"
    expected = { :app_id => 987, :created_at => creation_time}
    expect(client).to receive(:describe_apps).with({ :stack_id => 123}).and_return({:apps => [expected]})
    expect(client).to receive(:delete_app).with({:app_id => 987})

    actual_successes, actual_failures = ops.clean_apps 2

    actual_successes.count.should == 1
    actual_successes.first.should == expected

    actual_failures.count.should == 0
  end

  it "should ignore all existing OpsWorks apps before a certain age" do
    client = double(AWS::OpsWorks::Client)

    ops = Cloudpatrol::Task::OpsWorks.new({ :access_key_id => '', :secret_access_key => ''})
    ops.instance_variable_set '@gate', client

    expect(client).to receive(:describe_stacks).with(no_args()).and_return({ :stacks => [{ :stack_id => 123 }] })
    creation_time = "#{Time.now - 3.days}"
    expected = { :app_id => 987, :created_at => creation_time}
    expect(client).to receive(:describe_apps).with({ :stack_id => 123}).and_return({:apps => [expected]})

    actual_successes, actual_failures = ops.clean_apps 4

    actual_successes.count.should == 0

    actual_failures.count.should == 0
  end

  it "should handle errors cleaning when cleaning OpsWorks apps" do
    client = double(AWS::OpsWorks::Client)

    ops = Cloudpatrol::Task::OpsWorks.new({ :access_key_id => '', :secret_access_key => ''})
    ops.instance_variable_set '@gate', client

    expect(client).to receive(:describe_stacks).with(no_args()).and_return({ :stacks => [{ :stack_id => 123 }] })
    creation_time = "#{Time.now - 3.days}"
    expected = { :app_id => 987, :created_at => creation_time}
    expect(client).to receive(:describe_apps).with({ :stack_id => 123}).and_return({:apps => [expected]})
    expect(client).to receive(:delete_app).with({:app_id => 987}).and_raise(AWS::Errors::Base, "Failed to delete app")

    actual_successes, actual_failures = ops.clean_apps 2

    actual_successes.count.should == 0

    actual_failures.count.should == 1
    actual_failures.first.should == expected
  end

  it "should delete all OpsWorks instances after a certain age" do
    client = double(AWS::OpsWorks::Client)

    ops = Cloudpatrol::Task::OpsWorks.new({ :access_key_id => '', :secret_access_key => ''})
    ops.instance_variable_set '@gate', client

    expect(client).to receive(:describe_stacks).with(no_args()).and_return({ :stacks => [{ :stack_id => 123 }] })
    creation_time = "#{Time.now - 3.days}"
    expected = { :instance_id => 456, :created_at => creation_time}
    expect(client).to receive(:describe_instances).with({ :stack_id => 123 }).and_return({ :instances => [expected] })
    expect(client).to receive(:delete_instance).with({ :instance_id => 456 })

    actual_successes, actual_failures = ops.clean_instances 2

    actual_successes.count.should == 1
    actual_successes.first.should == expected

    actual_failures.count.should == 0
  end

  it "should ignore all OpsWorks instances before a certain age" do
    client = double(AWS::OpsWorks::Client)

    ops = Cloudpatrol::Task::OpsWorks.new({ :access_key_id => '', :secret_access_key => ''})
    ops.instance_variable_set '@gate', client

    expect(client).to receive(:describe_stacks).with(no_args()).and_return({ :stacks => [{ :stack_id => 123 }] })
    creation_time = "#{Time.now - 3.days}"
    expected = { :instance_id => 456, :created_at => creation_time}
    expect(client).to receive(:describe_instances).with({ :stack_id => 123 }).and_return({ :instances => [expected] })

    actual_successes, actual_failures = ops.clean_instances 4

    actual_successes.count.should == 0
    actual_failures.count.should == 0
  end

  it "should handle errors cleanly when deleting OpsWorks instances" do
    client = double(AWS::OpsWorks::Client)

    ops = Cloudpatrol::Task::OpsWorks.new({ :access_key_id => '', :secret_access_key => ''})
    ops.instance_variable_set '@gate', client

    expect(client).to receive(:describe_stacks).with(no_args()).and_return({ :stacks => [{ :stack_id => 123 }] })
    creation_time = "#{Time.now - 3.days}"
    expected = { :instance_id => 456, :created_at => creation_time}
    expect(client).to receive(:describe_instances).with({ :stack_id => 123 }).and_return({ :instances => [expected] })
    expect(client).to receive(:delete_instance).with({ :instance_id => 456 }).and_raise(AWS::Errors::Base, "Failed to delete instance")

    actual_successes, actual_failures = ops.clean_instances 2

    actual_successes.count.should == 0

    actual_failures.count.should == 1
    actual_failures.first.should == expected
  end


  it "should delete all OpsWorks layers after a certain age" do
    client = double(AWS::OpsWorks::Client)

    ops = Cloudpatrol::Task::OpsWorks.new({ :access_key_id => '', :secret_access_key => ''})
    ops.instance_variable_set '@gate', client

    expect(client).to receive(:describe_stacks).with(no_args()).and_return({ :stacks => [{ :stack_id => 123 }] })
    creation_time = "#{Time.now - 3.days}"
    expected = { :layer_id => 321, :created_at => creation_time}
    expect(client).to receive(:describe_layers).with({ :stack_id => 123 }).and_return({ :layers => [expected] })
    expect(client).to receive(:delete_layer).with({ :layer_id => 321 })

    actual_successes, actual_failures = ops.clean_layers 2

    actual_successes.count.should == 1
    actual_successes.first.should == expected

    actual_failures.count.should == 0
  end

  it "should ignore all OpsWorks layers before a certain age" do
    client = double(AWS::OpsWorks::Client)

    ops = Cloudpatrol::Task::OpsWorks.new({ :access_key_id => '', :secret_access_key => ''})
    ops.instance_variable_set '@gate', client

    expect(client).to receive(:describe_stacks).with(no_args()).and_return({ :stacks => [{ :stack_id => 123 }] })
    creation_time = "#{Time.now - 3.days}"
    expected = { :layer_id => 321, :created_at => creation_time}
    expect(client).to receive(:describe_layers).with({ :stack_id => 123 }).and_return({ :layers => [expected] })

    actual_successes, actual_failures = ops.clean_layers 4

    actual_successes.count.should == 0
    actual_failures.count.should == 0
  end

  it "should handle errrors cleanly when deleting OpsWorks layers" do
        client = double(AWS::OpsWorks::Client)

    ops = Cloudpatrol::Task::OpsWorks.new({ :access_key_id => '', :secret_access_key => ''})
    ops.instance_variable_set '@gate', client

    expect(client).to receive(:describe_stacks).with(no_args()).and_return({ :stacks => [{ :stack_id => 123 }] })
    creation_time = "#{Time.now - 3.days}"
    expected = { :layer_id => 321, :created_at => creation_time}
    expect(client).to receive(:describe_layers).with({ :stack_id => 123 }).and_return({ :layers => [expected] })
    expect(client).to receive(:delete_layer).with({ :layer_id => 321 }).and_raise(AWS::Errors::Base, "Failed to delete layer")

    actual_successes, actual_failures = ops.clean_layers 2

    actual_successes.count.should == 0

    actual_failures.count.should == 1
    actual_failures.first.should == expected
  end

  it "should delete all OpsWorks stacks after a certain age" do
    # simulates deleting an entire stack, including layers, apps, and instances, so it's a bit complex.
    client = double(AWS::OpsWorks::Client)

    ops = Cloudpatrol::Task::OpsWorks.new({ :access_key_id => '', :secret_access_key => ''})
    ops.instance_variable_set '@gate', client
    ops.instance_variable_set '@sleeptime', 0

    creation_time = "#{Time.now - 3.days}"
    expected_stack = { :stack_id => 123, :created_at => creation_time}
    expect(client).to receive(:describe_stacks).with(no_args()).at_least(3).times.and_return({ :stacks => [expected_stack] })

    expect(client).to receive(:describe_stacks).with({:stack_ids => [123]}).at_least(:once).and_return({ :stacks => [expected_stack] })
    
    expected_app = { :app_id => 987, :created_at => creation_time}
    expect(client).to receive(:describe_apps).with({ :stack_id => 123}).and_return({:apps => [expected_app]}, {:apps => [expected_app]}, {:apps => []})
    expect(client).to receive(:delete_app).with({:app_id => 987})

    expected_instance_online = { :instance_id => 456, :created_at => creation_time, :status => "online"}
    expected_instance_stopped = { :instance_id => 456, :created_at => creation_time, :status => "stopped"}
    expect(client).to receive(:describe_instances).with({:stack_id => 123}).and_return(
      {:instances => [expected_instance_online]},  # all stopped?
      {:instances => [expected_instance_online]},  # stop
      {:instances => [expected_instance_stopped]}, # all stoppped?
      {:instances => [expected_instance_stopped]}, # exist?
      {:instances => [expected_instance_stopped]}, # delete
      {:instances => []}  )                        # exist?
    expect(client).to receive(:stop_instance).with({ :instance_id => 456 }).exactly(:once)
    expect(client).to receive(:delete_instance).with({ :instance_id => 456 }).exactly(:once)
    expected_layer = { :layer_id => 321, :created_at => creation_time}
    expect(client).to receive(:describe_layers).with({:stack_id => 123}).and_return({:layers => [expected_layer]}, {:layers => [expected_layer]}, {:layers => []})
    expect(client).to receive(:delete_layer).with({ :layer_id => 321 }).exactly(:once)
    expect(client).to receive(:delete_stack).with({:stack_id => 123})

    actual_successes, actual_failures = ops.clean_stacks 2

    actual_successes.count.should == 1
    actual_successes.first.should == expected_stack

    actual_failures.count.should == 0
  end

  it "should ignore all OpsWorks stacks before a certain age" do
    client = double(AWS::OpsWorks::Client)

    ops = Cloudpatrol::Task::OpsWorks.new({ :access_key_id => '', :secret_access_key => ''})
    ops.instance_variable_set '@gate', client
    ops.instance_variable_set '@sleeptime', 0

    creation_time = "#{Time.now - 3.days}"
    expected_stack = { :stack_id => 123, :created_at => creation_time}
    expect(client).to receive(:describe_stacks).with(no_args()).times.and_return({ :stacks => [expected_stack] })

    
    actual_successes, actual_failures = ops.clean_stacks 4

    actual_successes.count.should == 0
    actual_failures.count.should == 0
  end

  it "should handle errrors cleanly when deleting OpsWorks stacks" do
    # simulates deleting an entire stack, including layers, apps, and instances, so it's a bit complex.
    client = double(AWS::OpsWorks::Client)

    ops = Cloudpatrol::Task::OpsWorks.new({ :access_key_id => '', :secret_access_key => ''})
    ops.instance_variable_set '@gate', client
    ops.instance_variable_set '@sleeptime', 0

    creation_time = "#{Time.now - 3.days}"
    expected_stack = { :stack_id => 123, :created_at => creation_time}
    expect(client).to receive(:describe_stacks).with(no_args()).at_least(3).times.and_return({ :stacks => [expected_stack] })

    expect(client).to receive(:describe_stacks).with({:stack_ids => [123]}).at_least(:once).and_return({ :stacks => [expected_stack] })
    
    expected_app = { :app_id => 987, :created_at => creation_time}
    expect(client).to receive(:describe_apps).with({ :stack_id => 123}).and_return({:apps => [expected_app]}, {:apps => [expected_app]}, {:apps => []})
    expect(client).to receive(:delete_app).with({:app_id => 987})

    expected_instance_online = { :instance_id => 456, :created_at => creation_time, :status => "online"}
    expected_instance_stopped = { :instance_id => 456, :created_at => creation_time, :status => "stopped"}
    expect(client).to receive(:describe_instances).with({:stack_id => 123}).and_return(
      {:instances => [expected_instance_online]},  # all stopped?
      {:instances => [expected_instance_online]},  # stop
      {:instances => [expected_instance_stopped]}, # all stoppped?
      {:instances => [expected_instance_stopped]}, # exist?
      {:instances => [expected_instance_stopped]}, # delete
      {:instances => []}  )                        # exist?
    expect(client).to receive(:stop_instance).with({ :instance_id => 456 }).exactly(:once)
    expect(client).to receive(:delete_instance).with({ :instance_id => 456 }).exactly(:once)
    expected_layer = { :layer_id => 321, :created_at => creation_time}
    expect(client).to receive(:describe_layers).with({:stack_id => 123}).and_return({:layers => [expected_layer]}, {:layers => [expected_layer]}, {:layers => []})
    expect(client).to receive(:delete_layer).with({ :layer_id => 321 }).exactly(:once)
    expect(client).to receive(:delete_stack).with({:stack_id => 123}).and_raise(AWS::Errors::Base, "Failed to delete stack.")

    actual_successes, actual_failures = ops.clean_stacks 2

    actual_successes.count.should == 0

    actual_failures.count.should == 1
    actual_failures.first.should == expected_stack
  end

  it "should handle errrors cleanly when deleting OpsWorks stacks" do
    client = double(AWS::OpsWorks::Client)

    ops = Cloudpatrol::Task::OpsWorks.new({ :access_key_id => '', :secret_access_key => ''})
    ops.instance_variable_set '@gate', client
    ops.instance_variable_set '@sleeptime', 0

    creation_time = "#{Time.now - 3.days}"
    expected_stack = { :stack_id => 123, :created_at => creation_time}
    expect(client).to receive(:describe_stacks).with(no_args()).times.and_return({ :stacks => [expected_stack] })

    expect(client).to receive(:describe_stacks).with({:stack_ids => [123]}).at_least(:once).and_return({ :stacks => [expected_stack] })
    
    expected_app = { :app_id => 987, :created_at => creation_time}
    expect(client).to receive(:describe_apps).with({ :stack_id => 123}).and_return({:apps => [expected_app]}, {:apps => [expected_app]})
    expect(client).to receive(:delete_app).with({:app_id => 987}).and_raise(AWS::Errors::Base, "Failed to delete app.")

    actual_successes, actual_failures = ops.clean_stacks 2

    actual_successes.count.should == 0

    actual_failures.count.should == 1
    actual_failures.first.should == expected_stack
  end


end

