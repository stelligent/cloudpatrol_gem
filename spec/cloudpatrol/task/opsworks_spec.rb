require 'Cloudpatrol'

describe Cloudpatrol::Task::OpsWorks do
  it "should be able to detect if a layer has running instances" do 
    # create a mock OpsWorks client that returns instances, and assert the method found them
    client = double(AWS::OpsWorks::Client)

    ops = Cloudpatrol::Task::OpsWorks.new Hash.new
    ops.instance_variable_set '@gate', client

    expect(client).to receive(:describe_stacks).and_return ({ :stacks => [{ :stack_id => 123 }]})
    expect(client).to receive(:describe_layers).and_return ({ :layers => [{ :instances => [] } ]})
    expect(client).to receive(:describe_instances).and_return ({ :instances => [ { :instance_id => 456 }, { :instance_id => 789} ]})

    actual = ops.does_layer_have_instances? 'layer'
    actual.should be_true
  end

  it "should be able to detect if a layer has no running instances" do 
    # create a mock OpsWorks client that returns no instances, and assert the method found none
    client = double(AWS::OpsWorks::Client)

    ops = Cloudpatrol::Task::OpsWorks.new Hash.new
    ops.instance_variable_set '@gate', client

    expect(client).to receive(:describe_stacks).and_return ({ :stacks => [{ :stack_id => 123 }]})
    expect(client).to receive(:describe_layers).and_return ({ :layers => [{ :instances => [] } ]})
    expect(client).to receive(:describe_instances).and_return ({ :instances => []})

    actual = ops.does_layer_have_instances? 'layer'
    actual.should be_false
  end

  it "should be able to stop all instances in a layer" do
    # create a mock OpsWorks client that returns instances, and assert the method found them
    client = double(AWS::OpsWorks::Client)

    ops = Cloudpatrol::Task::OpsWorks.new Hash.new
    ops.instance_variable_set '@gate', client

    expect(client).to receive(:describe_stacks).and_return ({ :stacks => [{ :stack_id => 123 }]})
    expect(client).to receive(:describe_layers).and_return ({ :layers => [{ :instances => [] } ]})
    expect(client).to receive(:describe_instances).and_return ({ :instances => [ { :instance_id => 456, :status => "running" }, { :instance_id => 789, :status => "stopped"} ]})
    expect(client).to receive(:stop_instance).with({ :instance_id => 456 })

    actual = ops.stop_all_instances_for_layer 'layer'
    actual.should be_true
  end 

end

