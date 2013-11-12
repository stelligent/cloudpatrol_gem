Feature: Scripted Deployment of an Application
    As a user of Amazon Web Services
    I would to use CloudPatrol's features
    so I can encourage best practices and lower costs.

    Scenario: CloudPatrol will clean CloudFormation stacks older than a certain age
    	When I use CloudPatrol to clean up CloudFormation stacks
    	Then any CloudFormation stacks older than the configured age should be deleted
    	And any CloudFormation stacks newer than the configured age should be left alone

    Scenario: CloudPatrol will clean IAM users that don't have MFAs
    	When I use CloudPatrol to clean IAM users
    	Then any IAM user without an MFA should be deleted
    	And any user with an MFA should be left alone
    	And any username starting with _ should be left alone

    Scenario: CloudPatrol will clean EC2 instances after a certain age
    	When I use CloudPatrol to clean EC2 instances
    	Then any EC2 instances older than the configured age should be deleted
    	And any EC2 instances newer than the configured age should be left alone

    Scenario: CloudPatrol will clean Elastic IPs not associated with any instance
    	When I use CloudPatrol to clean Elastic IPs
    	Then any Elastic IPs not associated with an EC2 instance should be deleted
    	And any Elastic IPs associated with an EC2 instance should be left alone

    Scenario: CloudPatrol will clean ports assigned to the default security group
    	When I use CloudPatrol to clean ports from the default security group
    	Then the default security group should contain no assigned ports

    Scenario: CloudPatrol will clean Security Groups that are no longer being used by any EC2 instances
    	When I use CloudPatrol to clean unused security groups
    	Then any security groups not associated with an EC2 instance should be deleted
    	And any security groups that are depended on by other security groups should be left alone

    Scenario: CloudPatrol will start all instances
    	When I use CloudPatrol to start all EC2 instances
    	Then all EC2 instances should be started

    Scenario: CloudPatrol will stop all instances
    	When I use CloudPatrol to stop all EC2 instances
    	Then all EC2 instances should be stopped

    Scenario: CloudPatrol will clean OpsWorks Apps after a certain age
    	When I use CloudPatrol to clean OpsWorks apps 
    	Then all OpsWorks apps older than the configured age should be deleted
    	And all OpsWorks apps newer than the configured age should be left alone

    Scenario: CloudPatrol will clean OpsWorks Instances after a certain age
    	When I use CloudPatrol to clean Opsworks instances
    	Then all OpsWorks instances older than the configured age should be deleted
    	And all OpsWorks instances newer than the configured age should be left alone

    Scenario: CloudPatrol will clean OpsWorks Layers after a certain age
    	When I use CloudPatrol to clean OpsWorks layers
    	Then all OpsWorks layers older than the configured age should be deleted
    	And all OpsWorks instances newer than the configured age should be left alone

    Scenario: CloudPatrol will clean OpsWorks Stacks after a certain age
    	When I use CloudPatrol to clean OpsWorks stacks
    	Then all OpsWorks stacks older than the configured age should be deleted
    	And all Opsworks instances newer than the configured age should be left alone

