require 'Cloudpatrol'

describe Cloudpatrol::Task::EC2 do

  it "should be able to stop all instances" do
    client = double(AWS::EC2)
    instance = double(AWS::EC2::Instance)

    ec2 = Cloudpatrol::Task::EC2.new Hash.new
    ec2.instance_variable_set '@gate', client

    expect(client).to receive(:instances).with(no_args()).and_return ([instance])
    expect(instance).to receive(:status).exactly(2).times.with(no_args()).and_return (:running)
    expect(instance).to receive(:stop).with(no_args())

    actual_success, actual_failures = ec2.stop_instances
    actual_success.size.should == 1
    actual_success.first.should == instance.inspect

    actual_failures.size.should == 0
  end

  it "should handle exceptions cleanly" do
    client = double(AWS::EC2)
    instance = double(AWS::EC2::Instance)

    ec2 = Cloudpatrol::Task::EC2.new Hash.new
    ec2.instance_variable_set '@gate', client

    expect(client).to receive(:instances).with(no_args()).and_return ([instance])
    expect(instance).to receive(:status).exactly(2).times.with(no_args()).and_return (:running)
    expect(instance).to receive(:stop).with(no_args()).and_raise(AWS::Errors::Base, "Failed to stop instance")

    actual_success, actual_failures = ec2.stop_instances
    actual_success.size.should == 0
    actual_failures.size.should == 1
  end

  it "should be able to start all instances" do
    client = double(AWS::EC2)
    instance = double(AWS::EC2::Instance)

    ec2 = Cloudpatrol::Task::EC2.new Hash.new
    ec2.instance_variable_set '@gate', client

    expect(client).to receive(:instances).with(no_args()).and_return ([instance])
    expect(instance).to receive(:start).with(no_args())

    actual_success, actual_failures = ec2.start_instances
    actual_success.size.should == 1
    actual_success.first.should == instance.inspect

    actual_failures.size.should == 0
  end

  it "should handle exceptions cleanly" do
    client = double(AWS::EC2)
    instance = double(AWS::EC2::Instance)

    ec2 = Cloudpatrol::Task::EC2.new Hash.new
    ec2.instance_variable_set '@gate', client

    expect(client).to receive(:instances).with(no_args()).and_return ([instance])
    expect(instance).to receive(:start).with(no_args()).and_raise(AWS::Errors::Base, "Failed to start instance")

    actual_success, actual_failures = ec2.start_instances
    actual_success.size.should == 0
    actual_failures.size.should == 1
  end

  it "should be able to stop all instances" do
    client = double(AWS::EC2)
    instance = double(AWS::EC2::Instance)

    ec2 = Cloudpatrol::Task::EC2.new Hash.new
    ec2.instance_variable_set '@gate', client

    expect(client).to receive(:instances).with(no_args()).and_return ([instance])
    expect(instance).to receive(:status).with(no_args()).and_return (:running)
    expect(instance).to receive(:launch_time).with(no_args()).and_return (1)
    expect(instance).to receive(:delete).with(no_args())

    actual_success, actual_failures = ec2.clean_instances 0
    actual_success.size.should == 1
    actual_success.first.should == instance.inspect

    actual_failures.size.should == 0
  end

  it "should handle exceptions cleanly" do
    client = double(AWS::EC2)
    instance = double(AWS::EC2::Instance)

    ec2 = Cloudpatrol::Task::EC2.new Hash.new
    ec2.instance_variable_set '@gate', client

    expect(client).to receive(:instances).with(no_args()).and_return ([instance])
    expect(instance).to receive(:status).with(no_args()).and_return (:running)
    expect(instance).to receive(:launch_time).with(no_args()).and_return (0)
    expect(instance).to receive(:delete).with(no_args()).and_raise(AWS::Errors::Base, "Failed to stop instance")

    actual_success, actual_failures = ec2.clean_instances 0
    actual_success.size.should == 0
    actual_failures.size.should == 1
  end


  it "should clean out unused elastic ips" do
    client = double(AWS::EC2)
    eip = double(AWS::EC2::ElasticIp)

    ec2 = Cloudpatrol::Task::EC2.new Hash.new
    ec2.instance_variable_set '@gate', client

    expect(client).to receive(:elastic_ips).with(no_args()).and_return([eip])
    expect(eip).to receive(:instance).with(no_args()).and_return(nil)
    expect(eip).to receive(:release).with(no_args())

    actual_successes, actual_failures = ec2.clean_elastic_ips
    actual_successes.count.should == 1
    actual_successes.first.should == eip.inspect
    
    actual_failures.count.should == 0
  end

  it "should handle exceptions cleanly" do
    client = double(AWS::EC2)
    eip = double(AWS::EC2::ElasticIp)

    ec2 = Cloudpatrol::Task::EC2.new Hash.new
    ec2.instance_variable_set '@gate', client

    expect(client).to receive(:elastic_ips).with(no_args()).and_return([eip])
    expect(eip).to receive(:instance).with(no_args()).and_return(nil)
    expect(eip).to receive(:release).with(no_args()).and_raise(AWS::Errors::Base, "Failed to release Elastic IP")

    actual_successes, actual_failures = ec2.clean_elastic_ips    
  end

end
