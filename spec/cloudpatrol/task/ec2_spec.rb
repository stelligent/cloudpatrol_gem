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

    actual = ec2.stop_instances
    actual.size.should == 1
    actual.first.should == instance.inspect
  end

  it "should handle exceptions cleanly" do
    client = double(AWS::EC2)
    instance = double(AWS::EC2::Instance)

    ec2 = Cloudpatrol::Task::EC2.new Hash.new
    ec2.instance_variable_set '@gate', client

    expect(client).to receive(:instances).with(no_args()).and_return ([instance])
    expect(instance).to receive(:status).exactly(2).times.with(no_args()).and_return (:running)
    expect(instance).to receive(:stop).with(no_args()).and_raise(AWS::Errors::Base, "Failed to delete instance")
    expect(instance).to receive(:id).with(no_args()).and_return("i-1234567890")

    actual = ec2.stop_instances
    actual.size.should == 0
  end
end
