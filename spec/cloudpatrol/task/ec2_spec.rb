require 'spec_helper'

describe Cloudpatrol::Task::EC2 do

  describe 'stop instances' do
    it "should be able to stop all instances" do
      client = double(AWS::EC2)
      instance = double(AWS::EC2::Instance)

      ec2 = Cloudpatrol::Task::EC2.new({ :access_key_id => '', :secret_access_key => ''})
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

      ec2 = Cloudpatrol::Task::EC2.new ({ :access_key_id => '', :secret_access_key => ''})
      ec2.instance_variable_set '@gate', client

      expect(client).to receive(:instances).with(no_args()).and_return ([instance])
      expect(instance).to receive(:status).exactly(2).times.with(no_args()).and_return (:running)
      expect(instance).to receive(:stop).with(no_args()).and_raise(AWS::Errors::Base, "Failed to stop instance")

      actual_success, actual_failures = ec2.stop_instances
      actual_success.size.should == 0
      actual_failures.size.should == 1
    end
  end

  describe 'start instances' do
    it "should be able to start all instances" do
      client = double(AWS::EC2)
      instance = double(AWS::EC2::Instance)

      ec2 = Cloudpatrol::Task::EC2.new({ :access_key_id => '', :secret_access_key => ''})
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

      ec2 = Cloudpatrol::Task::EC2.new({ :access_key_id => '', :secret_access_key => ''})
      ec2.instance_variable_set '@gate', client

      expect(client).to receive(:instances).with(no_args()).and_return ([instance])
      expect(instance).to receive(:start).with(no_args()).and_raise(AWS::Errors::Base, "Failed to start instance")

      actual_success, actual_failures = ec2.start_instances
      actual_success.size.should == 0
      actual_failures.size.should == 1
    end
  end

  describe 'clean instances' do
    it 'should be able to delete all instances' do
      instance = ec2_instance_not_in_opsworks

      client = double(AWS::EC2)
      expect(client).to receive(:instances)
        .with(no_args)
        .and_return ([instance])

      ec2 = Cloudpatrol::Task::EC2.new({ :access_key_id => '', :secret_access_key => ''})
      ec2.instance_variable_set '@gate', client

      actual_success, actual_failures = ec2.clean_instances 0
      actual_success.size.should == 1
      actual_success.first.should == instance.inspect

      actual_failures.size.should == 0
    end

    it 'should ignore opsworks instances' do
      instances = [ec2_instance_not_in_opsworks, ec2_instance_in_opsworks]

      client = double(AWS::EC2)
      expect(client).to receive(:instances)
        .with(no_args)
        .and_return (instances)

      ec2 = Cloudpatrol::Task::EC2.new({ :access_key_id => '', :secret_access_key => ''})
      ec2.instance_variable_set '@gate', client

      actual_success, actual_failures = ec2.clean_instances 0
      actual_success.size.should == 1
      actual_success.first.should == instances[0].inspect

      actual_failures.size.should == 1
      actual_failures.first.should == instances[1].inspect
    end

    it 'should ignore instances in the white list' do
      instances = [ec2_instance_with_id('instance1'), ec2_instance_not_in_opsworks]

      client = double(AWS::EC2)
      expect(client).to receive(:instances)
                        .with(no_args)
                        .and_return (instances)

      ec2 = Cloudpatrol::Task::EC2.new({ :access_key_id => '', :secret_access_key => ''})
      ec2.instance_variable_set '@gate', client

      actual_success, actual_failures = ec2.clean_instances 0, whitelist=%w{instance1}
      actual_success.size.should == 1
      actual_success.first.should == instances[1].inspect

      actual_failures.size.should == 1
      actual_failures.first.should == instances[0].inspect

    end

    it 'should handle exceptions cleanly' do
      client = double(AWS::EC2)
      instance = double(AWS::EC2::Instance)

      ec2 = Cloudpatrol::Task::EC2.new ({ :access_key_id => '', :secret_access_key => ''})
      ec2.instance_variable_set '@gate', client

      ec2.stub(:is_opsworks_instance) { false }
      expect(client).to receive(:instances).with(no_args()).and_return ([instance])
      expect(instance).to receive(:status).with(no_args()).and_return (:running)
      expect(instance).to receive(:api_termination_disabled=).with(false)
      expect(instance).to receive(:launch_time).with(no_args()).and_return (0)
      expect(instance).to receive(:delete).with(no_args()).and_raise(AWS::Errors::Base, "Failed to stop instance")

      expect(instance).to receive(:instance_id)
        .with(no_args)
        .and_return('dontcare')

      actual_success, actual_failures = ec2.clean_instances 0
      actual_success.size.should == 0
      actual_failures.size.should == 1
    end

    def ec2_instance_with_id instance_id
      instance = double(AWS::EC2::Instance)

      expect(instance).to receive(:instance_id)
        .with(no_args)
        .and_return(instance_id)

      expect(instance).to receive(:status).with(no_args()).and_return (:running)
      expect(instance).to receive(:launch_time).with(no_args()).and_return (1)

      tags = double(AWS::EC2::TagCollection)
      expect(tags).to receive(:to_h)
        .with(no_args)
        .and_return({})

      expect(instance).to receive(:tags)
        .with(no_args)
        .and_return (tags)
      instance
    end

    def ec2_instance_not_in_opsworks
      instance = double(AWS::EC2::Instance)

      expect(instance).to receive(:status).with(no_args()).and_return (:running)
      expect(instance).to receive(:api_termination_disabled=).with(false)
      expect(instance).to receive(:launch_time).with(no_args()).and_return (1)
      expect(instance).to receive(:delete).with(no_args())

      expect(instance).to receive(:instance_id)
        .with(no_args)
        .and_return('dontcare')

      tags = double(AWS::EC2::TagCollection)
      expect(tags).to receive(:to_h)
        .with(no_args)
        .and_return({})

      expect(instance).to receive(:tags)
        .with(no_args)
        .and_return (tags)
      instance
    end

    def ec2_instance_in_opsworks
      tags = double(AWS::EC2::TagCollection)
      expect(tags).to receive(:to_h)
        .with(no_args)
        .and_return({'opsworks:instance' => 'cloudpatrol'})

      instance = double(AWS::EC2::Instance)
      expect(instance).to receive(:tags)
        .with(no_args)
        .and_return (tags)

      instance
    end
  end

  describe 'clean elastic ips' do
    it "should clean out unused elastic ips" do
      client = double(AWS::EC2)
      eip = double(AWS::EC2::ElasticIp)

      ec2 = Cloudpatrol::Task::EC2.new ({ :access_key_id => '', :secret_access_key => ''})
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

      ec2 = Cloudpatrol::Task::EC2.new ({ :access_key_id => '', :secret_access_key => ''})
      ec2.instance_variable_set '@gate', client

      expect(client).to receive(:elastic_ips).with(no_args()).and_return([eip])
      expect(eip).to receive(:instance).with(no_args()).and_return(nil)
      expect(eip).to receive(:release).with(no_args()).and_raise(AWS::Errors::Base, "Failed to release Elastic IP")

      actual_successes, actual_failures = ec2.clean_elastic_ips
      actual_successes.count.should == 0

      actual_failures.count.should == 1
      actual_failures.first.should == eip.inspect
    end
  end

  describe 'clean ports in default' do
    it "should delete ports assigned to the default security group" do
      # okay this is kind of excessive and we should clean this up
      client = double(AWS::EC2)
      sgc = double(AWS::EC2::SecurityGroupCollection)
      sg = double(AWS::EC2::SecurityGroup)
      perm = double(AWS::EC2::SecurityGroup::IpPermission)

      ec2 = Cloudpatrol::Task::EC2.new({ :access_key_id => '', :secret_access_key => ''})
      ec2.instance_variable_set '@gate', client

      expect(client).to receive(:security_groups).with(no_args()).and_return(sgc)
      expect(sgc).to receive(:filter).with("group-name", "default").and_return([sg])
      expect(sg).to receive(:ingress_ip_permissions).and_return([perm])
      expect(perm).to receive(:revoke)
      expect(perm).to receive(:port_range).and_return(0..65535)

      actual_successes, actual_failures = ec2.clean_ports_in_default
      actual_successes.count.should == 1
      actual_successes.first.should == {:port_range => 0..65535}

      actual_failures.count.should == 0
    end

    it "should handle exceptions cleanly" do
      client = double(AWS::EC2)
      sgc = double(AWS::EC2::SecurityGroupCollection)
      sg = double(AWS::EC2::SecurityGroup)
      perm = double(AWS::EC2::SecurityGroup::IpPermission)

      ec2 = Cloudpatrol::Task::EC2.new ({ :access_key_id => '', :secret_access_key => ''})
      ec2.instance_variable_set '@gate', client

      expect(client).to receive(:security_groups).with(no_args()).and_return(sgc)
      expect(sgc).to receive(:filter).with("group-name", "default").and_return([sg])
      expect(sg).to receive(:ingress_ip_permissions).and_return([perm])
      expect(perm).to receive(:revoke).and_raise(AWS::Errors::Base, "Failed to revoke permission")
      expect(perm).to receive(:port_range).and_return(0..65535)

      actual_successes, actual_failures = ec2.clean_ports_in_default
      actual_successes.count.should == 0

      actual_failures.count.should == 1
      actual_failures.first.should == {:port_range => 0..65535}
    end
  end

  describe 'clean security groups' do
    it "should delete unused security groups" do
      client = double(AWS::EC2)
      sg = double(AWS::EC2::SecurityGroup)
      perm = double(AWS::EC2::SecurityGroup::IpPermission)

      ec2 = Cloudpatrol::Task::EC2.new ({ :access_key_id => '', :secret_access_key => ''})
      ec2.instance_variable_set '@gate', client

      expect(client).to receive(:security_groups).exactly(2).times.and_return([sg])
      expect(sg).to receive(:ip_permissions).and_return([perm])
      expect(perm).to receive(:groups).and_return([])
      expect(sg).to receive(:exists?).and_return(true)
      expect(sg).to receive(:instances).and_return([])
      expect(sg).to receive(:name).and_return("test_security_group")
      expect(sg).to receive(:delete)

      actual_successes, actual_failures = ec2.clean_security_groups

      actual_successes.count.should == 1
      actual_successes.first.should == sg.inspect

      actual_failures.count.should == 0
    end
    it "should delete unused security groups" do
      client = double(AWS::EC2)
      sg = double(AWS::EC2::SecurityGroup)
      perm = double(AWS::EC2::SecurityGroup::IpPermission)

      ec2 = Cloudpatrol::Task::EC2.new ({ :access_key_id => '', :secret_access_key => ''})
      ec2.instance_variable_set '@gate', client

      expect(client).to receive(:security_groups).exactly(2).times.and_return([sg])
      expect(sg).to receive(:ip_permissions).and_return([perm])
      expect(perm).to receive(:groups).and_return([])
      expect(sg).to receive(:exists?).and_return(true)
      expect(sg).to receive(:instances).and_return([])
      expect(sg).to receive(:name).and_return("test_security_group")
      expect(sg).to receive(:delete).and_raise(AWS::Errors::Base, "Failed to delete security group")

      actual_successes, actual_failures = ec2.clean_security_groups

      actual_successes.count.should == 0

      actual_failures.count.should == 1
      actual_failures.first.should == sg.inspect
    end
  end
end