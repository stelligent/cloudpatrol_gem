cloudpatrol_gem
===============

Ruby Gem for CloudPatrol

==============

## Description

CloudPatrol lets you establish and automatically enforce team policies for your Amazon Web Services account through a Command Line Interface (CLI).

While Ruby can be installed on many operating systems, we've included detailed instructions for installing on Ubuntu 12.04 LTS. With minor alterations, you can run these instructions for other operating systems.
## Configuration of Linux Instance

You'll need to first download and install Ubuntu 12.04 LTS. To do this, go to [Ubuntu](http://releases.ubuntu.com/precise/).


## Installation of Rails on Ubuntu 12.04 LTS

After you've installed Ubunu, follow the instructions below (which were adpated from [digitalocean](https://www.digitalocean.com/community/articles/how-to-install-ruby-on-rails-on-ubuntu-12-04-lts-precise-pangolin-with-rvm))

1. ```sudo apt-get update```
1. ```sudo apt-get install curl nodejs git```
1. ```\curl -L https://get.rvm.io | bash -s stable```
1. ```source ~/.rvm/scripts/rvm```
1. ```rvm requirements```
1. ```rvm install 2.0.0```
1. ```rvm use 2.0.0 --default```
1. ```rvm rubygems current```

## Installation of CloudPatrol Gem

Now that you've intalled Ruby and other packages, you will install CloudPatrol gem on this instance.

1. ```git clone https://github.com/stelligent/cloudpatrol_gem.git```
1. ```bundle install```
1. ```cd ~/cloudpatrol_gem```

## Example CLI Snippets

Now that you've intalled the CloudPatrol CLI, you can begin using it through the command line. There's also a Rails web app that you can download and use [here](https://github.com/stelligent/cloudpatrol)

Currently, there are four services that CloudPatrol can manage. They are cloudformation, ec2, iam and opsworks. To get a listing of all the services and options that CloudPatrol provides, type:

```bundle exec bin/cloudpatrol --aws_access_key_id=ID --aws_secret_access_key=KEY cloudpatrol```

To get a listing of the methods you can use for a service, enter help next to the service name. For example:

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
