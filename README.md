CloudPatrol Ruby Gem
===============

Ruby Gem for CloudPatrol. For information on our feature roadmap, go to the [Roadmap](https://github.com/stelligent/cloudpatrol_gem/blob/master/ROADMAP.md)

==============

## Description

CloudPatrol lets you establish and automatically enforce team policies for your Amazon Web Services account through a Command Line Interface (CLI).

There's also a corresponding [Rails web app](https://github.com/stelligent/cloudpatrol) that you can download and use [here](https://github.com/stelligent/cloudpatrol). For more information on creating new rules/tasks, see [ Creating a new Task/Rule in CloudPatrol](https://github.com/stelligent/cloudpatrol_gem/blob/master/CREATING_NEW_TASK.md).

While Ruby can be installed on many operating systems, we've included detailed instructions for installing on Ubuntu 12.04 LTS. With minor alterations, you can run these instructions for other operating systems.

## Configuration of Ubuntu 12.04 LTS Instance

Since you will be using [AWS EC2](https://console.aws.amazon.com/ec2/) to install Ubuntu, choose the Ubuntu 12.04 LTS 64-bit option when launching your EC2 instance.

## Installing Rails on Ubuntu 12.04 LTS

After you've installed Ubunu, follow the instructions below.

1. ```sudo apt-get update```
1. ```sudo apt-get -y install curl nodejs git```
1. ```\curl -L https://get.rvm.io | bash -s stable```
1. ```source ~/.rvm/scripts/rvm```
1. ```rvm requirements```
1. ```rvm install 1.9.3```
1. ```rvm use 1.9.3 --default```
1. ```rvm rubygems current```

## Installing CloudPatrol Gem

Now that you've intalled Ruby and other packages, you will install CloudPatrol gem on this instance.

1. ```git clone https://github.com/stelligent/cloudpatrol_gem.git```
1. ```cd ~/cloudpatrol_gem```
1. ```bundle install```

## Example CLI Snippets

Now that you've intalled the CloudPatrol CLI, you can begin using it through the command line. There's also a Rails web app that you can download and use [here](https://github.com/stelligent/cloudpatrol).

Currently, there are four services that CloudPatrol can manage. They are ```cloudformation```, ```ec2```, ```iam``` and ```opsworks```. To get a listing of all the services and options that CloudPatrol provides, type:

```bundle exec bin/cloudpatrol --aws_access_key_id=ID --aws_secret_access_key=KEY cloudpatrol```

To get a listing of the methods you can use for a service, enter ```help``` next to the service name. For example:

```bundle exec bin/cloudpatrol --aws_access_key_id=ID --aws_secret_access_key=KEY ec2 help```
 
Here are some code snippets to use the CloudPatrol CLI 

1. ```bundle exec bin/cloudpatrol --aws_access_key_id=ID --aws_secret_access_key=KEY cloudformation clean-stacks --days=2```
1. ```bundle exec bin/cloudpatrol --region=us-east-1 --aws_access_key_id=ID --aws_secret_access_key=KEY ec2 clean-instances --days=1``` 
1. ```bundle exec bin/cloudpatrol --aws_access_key_id=ID --aws_secret_access_key=KEY ec2 clean-security-groups```
1. ```bundle exec bin/cloudpatrol --aws_access_key_id=ID --aws_secret_access_key=KEY ec2 stop-instances --days=2```
1. ```bundle exec bin/cloudpatrol --aws_access_key_id=ID --aws_secret_access_key=KEY ec2 start-instances```
1. ```bundle exec bin/cloudpatrol --aws_access_key_id=ID --aws_secret_access_key=KEY iam clean-users```
1. ```bundle exec bin/cloudpatrol --aws_access_key_id=ID --aws_secret_access_key=KEY opsworks clean-stacks --days=2```
1. ```bundle exec bin/cloudpatrol --aws_access_key_id=ID --aws_secret_access_key=KEY opsworks clean-layers --days=2```
1. ```bundle exec bin/cloudpatrol --aws_access_key_id=ID --aws_secret_access_key=KEY opsworks clean-instances --days=2```
1. ```bundle exec bin/cloudpatrol --aws_access_key_id=ID --aws_secret_access_key=KEY opsworks clean-apps --days=2```

## LICENSE

Copyright (c) 2013 Stelligent Systems LLC

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
