require 'spec_helper'

describe Cloudpatrol::Task::CloudFormation do

  it "should be remove cloudformation stacks over a certain age" do
    client = double(AWS::CloudFormation)
    stack = double(AWS::CloudFormation::Stack)

    cfn = Cloudpatrol::Task::CloudFormation.new({ :access_key_id => '', :secret_access_key => ''})
    cfn.instance_variable_set '@gate', client

    expect(client).to receive(:stacks).with(no_args()).and_return([stack])
    expect(stack).to receive(:creation_time).with(no_args()).and_return(Time.now - 3 * 24 * 60 * 60)
    expect(stack).to receive(:delete).with(no_args())

    actual_successes, actual_failures = cfn.clean_stacks 2

    actual_successes.count.should == 1
    actual_successes.first.should == stack.inspect

    actual_failures.count.should == 0
  end

  it "it shouldn't delete stacks before a certain age" do
    client = double(AWS::CloudFormation)
    stack = double(AWS::CloudFormation::Stack)

    cfn = Cloudpatrol::Task::CloudFormation.new({ :access_key_id => '', :secret_access_key => ''})
    cfn.instance_variable_set '@gate', client

    expect(client).to receive(:stacks).with(no_args()).and_return([stack])
    expect(stack).to receive(:creation_time).with(no_args()).and_return(Time.now - (3 * 24 * 60 * 60))

    actual_successes, actual_failures = cfn.clean_stacks 4

    actual_successes.count.should == 0
    actual_failures.count.should == 0

  end

  it "should handle AWS exceptions cleanly" do
    client = double(AWS::CloudFormation)
    stack = double(AWS::CloudFormation::Stack)

    cfn = Cloudpatrol::Task::CloudFormation.new ({ :access_key_id => '', :secret_access_key => ''})
    cfn.instance_variable_set '@gate', client

    expect(client).to receive(:stacks).with(no_args()).and_return([stack])
    expect(stack).to receive(:creation_time).with(no_args()).and_return(Time.now - (3 * 24 * 60 * 60))
    expect(stack).to receive(:delete).with(no_args()).and_raise(AWS::Errors::Base, "Failed to delete stack")

    actual_successes, actual_failures = cfn.clean_stacks 0

    actual_successes.count.should == 0
    actual_failures.count.should == 1
    actual_failures.first.should == stack.inspect
  end

end