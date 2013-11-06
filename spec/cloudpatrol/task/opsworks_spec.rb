require 'Cloudpatrol'

# Know what's really hard to find online? A list of all the possible status an opsowrks instance can be in
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
  it "should be able to detect if a stack has running instances" do 
    # create a mock OpsWorks client that returns instances, and assert the method found them
    client = double(AWS::OpsWorks::Client)

    ops = Cloudpatrol::Task::OpsWorks.new Hash.new
    ops.instance_variable_set '@gate', client

    expect(client).to receive(:describe_stacks).with({ :stack_ids => [123] }).and_return ({ :stacks => [{ :stack_id => 123 }]})
    expect(client).to receive(:describe_instances).with({ :stack_id => 123 }).and_return ({ :instances => [ { :instance_id => 456 }, { :instance_id => 789} ]})

    actual = ops.does_stack_have_instances? 123
    actual.should be_true
  end

  it "should be able to detect if a stack has no running instances" do 
    # create a mock OpsWorks client that returns no instances, and assert the method found none
    client = double(AWS::OpsWorks::Client)

    ops = Cloudpatrol::Task::OpsWorks.new Hash.new
    ops.instance_variable_set '@gate', client

    expect(client).to receive(:describe_stacks).with({ :stack_ids => [123] }).and_return ({ :stacks => [{ :stack_id => 123 }]})
    expect(client).to receive(:describe_instances).with({ :stack_id => 123 }).and_return ({ :instances => []})

    actual = ops.does_stack_have_instances? 123
    actual.should be_false
  end

  it "should be able to stop all instances in a stack" do
    # create a mock OpsWorks client that returns instances, and assert the method found them
    client = double(AWS::OpsWorks::Client)

    ops = Cloudpatrol::Task::OpsWorks.new Hash.new
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

    ops = Cloudpatrol::Task::OpsWorks.new Hash.new
    ops.instance_variable_set '@gate', client

    expect(client).to receive(:describe_stacks).with({ :stack_ids => [123] }).and_return ({ :stacks => [{ :stack_id => 123 }]})
    expect(client).to receive(:describe_instances).with({ :stack_id => 123 }).and_return ({ :instances => [ { :instance_id => 456, :status => "stopped" }, { :instance_id => 789, :status => "stopped"} ]})

    actual = ops.are_all_instances_stopped_for_stack? 123
    actual.should be_true
  end 

  it "should be able to determine if any instances in a layer are running" do
    # create a mock OpsWorks client that returns instances, and assert the method found them
    client = double(AWS::OpsWorks::Client)

    ops = Cloudpatrol::Task::OpsWorks.new Hash.new
    ops.instance_variable_set '@gate', client

    expect(client).to receive(:describe_stacks).with({ :stack_ids => [123] }).and_return ({ :stacks => [{ :stack_id => 123 }]})
    expect(client).to receive(:describe_instances).with({ :stack_id => 123 }).and_return ({ :instances => [ { :instance_id => 456, :status => "online" }, { :instance_id => 789, :status => "stopped"} ]})

    actual = ops.are_all_instances_stopped_for_stack? 123
    actual.should be_false
  end 

  it "should be able to delete all instances in a stack" do
    # create a mock OpsWorks client that returns instances, and assert the method found them
    client = double(AWS::OpsWorks::Client)

    ops = Cloudpatrol::Task::OpsWorks.new Hash.new
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

    ops = Cloudpatrol::Task::OpsWorks.new Hash.new
    ops.instance_variable_set '@gate', client

    expect(client).to receive(:describe_stacks).with(no_args()).and_return ({ :stacks => [{ :stack_id => 123 }]})
    expect(client).to receive(:describe_layers).with({ :stack_id => 123 }).and_return ({ :layers => [{ :instances => [] } ]})
  
    actual = ops.does_stack_have_layers? 123
    actual.should be_true
  end 

  it "should be able to determine if there are not any layers in a stack" do
    # create a mock OpsWorks client that returns instances, and assert the method found them
    client = double(AWS::OpsWorks::Client)

    ops = Cloudpatrol::Task::OpsWorks.new Hash.new
    ops.instance_variable_set '@gate', client

    expect(client).to receive(:describe_stacks).with(no_args()).and_return ({ :stacks => [{ :stack_id => 123 }]})
    expect(client).to receive(:describe_layers).with({ :stack_id => 123 }).and_return ({ :layers => []})
  
    actual = ops.does_stack_have_layers? 123
    actual.should be_false
  end 

  # this test does a lot of looping while waiting for state changes. it can be tested, but it's going to require more time than I'm willing to dedicate to it today
  # it "should be able to delete a stack and all associated resources" do
  #   # create a mock OpsWorks client that returns instances, and assert the method found them
  #   client = double(AWS::OpsWorks::Client)

  #   ops = Cloudpatrol::Task::OpsWorks.new Hash.new
  #   ops.instance_variable_set '@gate', client
  #   ops.instance_variable_set '@sleeptime', 0

  #   expect(client).to receive(:describe_stacks).exactly(3).times.and_return ({ :stacks => [{ :stack_id => 123 }]})
  #   expect(client).to receive(:describe_layers).exactly(4).times.and_return ({ :layers => [{ :layer_id => 321, :instances => [] } ]})
  #   expect(client).to receive(:describe_instances).times.and_return ({ :instances => [ { :instance_id => 456, :status => "online" }, { :instance_id => 789, :status => "shutdown"} ]})
  #   expect(client).to receive(:stop_instance).with({ :instance_id => 456 })
  #   expect(client).to receive(:stop_instance).with({ :instance_id => 789 })
  #   expect(client).to receive(:delete_instance).with({ :instance_id => 456 } )
  #   expect(client).to receive(:delete_instance).with({ :instance_id => 789 } )
  #   expect(client).to receive(:delete_layer).with({ :layer_id => 789 } )
  #   expect(client).to receive(:delete_stack).with({ :stack_id => 123467890 } )


  #   actual = ops.delete_stack_and_associated_resources 123467890

  #   actual.should be_true
  # end 
end

