require 'Cloudpatrol'

describe Cloudpatrol::Task::IAM do

  it "should be delete users without MFAs" do
    client = double(AWS::IAM)
    user = double(AWS::IAM::User)
    mfacollection = double(AWS::IAM::MFADeviceCollection)

    iam = Cloudpatrol::Task::IAM.new Hash.new
    iam.instance_variable_set '@gate', client

    expect(client).to receive(:users).with(no_args()).and_return ([user])
    expect(user).to receive(:name).with(no_args()).and_return("batman")
    expect(user).to receive(:mfa_devices).with(no_args()).and_return(mfacollection)
    expect(user).to receive(:delete!).with(no_args())
    expect(mfacollection).to receive(:count).and_return(0)


    actual_success, actual_failures = iam.clean_users
    actual_success.count.should == 1
    actual_success.first.should == user.inspect

    actual_failures.count.should == 0
  end

  it "shouldn't delete users that start with _" do
    client = double(AWS::IAM)
    user = double(AWS::IAM::User)
    mfacollection = double(AWS::IAM::MFADeviceCollection)

    iam = Cloudpatrol::Task::IAM.new Hash.new
    iam.instance_variable_set '@gate', client

    expect(client).to receive(:users).with(no_args()).and_return ([user])
    expect(user).to receive(:name).and_return("_batman")

    actual_success, actual_failures = iam.clean_users
    actual_success.count.should == 0
    actual_failures.count.should == 0
  end

  it "shouldn't delete users with MFAs" do
    client = double(AWS::IAM)
    user = double(AWS::IAM::User)
    mfacollection = double(AWS::IAM::MFADeviceCollection)

    iam = Cloudpatrol::Task::IAM.new Hash.new
    iam.instance_variable_set '@gate', client

    expect(client).to receive(:users).with(no_args()).and_return ([user])
    expect(user).to receive(:name).with(no_args()).and_return("batman")
    expect(user).to receive(:mfa_devices).with(no_args()).and_return(mfacollection)
    expect(mfacollection).to receive(:count).and_return(1)


    actual_success, actual_failures = iam.clean_users
    actual_success.count.should == 0
    actual_failures.count.should == 0
  end

  it "should handle AWS exceptions cleanly" do
    client = double(AWS::IAM)
    user1 = double(AWS::IAM::User)
    user2 = double(AWS::IAM::User)
    mfacollection = double(AWS::IAM::MFADeviceCollection)

    iam = Cloudpatrol::Task::IAM.new Hash.new
    iam.instance_variable_set '@gate', client

    expect(client).to receive(:users).with(no_args()).and_return ([user1, user2])
    expect(user1).to receive(:name).times.with(no_args()).and_return("batman1")
    expect(user1).to receive(:mfa_devices).with(no_args()).and_return(mfacollection)
    expect(user1).to receive(:delete!).and_raise(AWS::Errors::Base, "Test exception")

    expect(user2).to receive(:name).with(no_args()).and_return("batman2")
    expect(user2).to receive(:mfa_devices).with(no_args()).and_return(mfacollection)
    expect(user2).to receive(:delete!).with(no_args())
    expect(mfacollection).to receive(:count).exactly(2).times.and_return(0)

    actual_success, actual_failures = iam.clean_users
    actual_success.count.should == 1
    actual_success.first.should == user2.inspect

    actual_failures.count.should == 1
    actual_failures.first.should == user1.inspect
  end

end