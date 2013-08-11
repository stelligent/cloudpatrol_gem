Creating a new Task/Rule in CloudPatrol
==============

## Description

A new rule in CloudPatrol describes a set a tasks that will be performed on a schedule basis as part of CloudPatrol. From the Ruby gem, Tasks/Rules in CloudPatrol can be run from the command line and can be integrated into the Rails application. For more information for configuring the Rails app to call the Ruby Gem rule, see [Rails web app](https://github.com/stelligent/cloudpatrol).


## Steps for Creating a New CloudPatrol Task

Adding a new task for any service comes down to adding a method to corresponding class and exposing this new method in CLI/Rails. Let’s say the class is ```Cloudpatrol::Task::EC2``` and the method is ```#do_something```. This method should utilize EC2 gateway populated by constructor (```@gate```), obviously it should do something, and it should return an array of affected entities, be it modified Security Groups or deleted Key Pairs (it will be logged to DynamoDB and displayed in CLI with log switch).

Call ```Cloudpatrol::Task::EC2#do_something``` only indirectly by calling an adapter method ```Cloudpatrol.perform(aws_creds, log_table, :EC2, :do_something, optional_args*)``` that not only calls ```#do_something``` but also formats output, rescues exceptions and logs to DynamoDB.

Use existing commands and subcommands in gem’s ```bin/cloudpatrol``` file as a reference when adding the task to CLI.