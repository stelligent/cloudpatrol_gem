Feature: Scripted Deployment of an Application
    As a developer of CloudPatrol
    I would to automatically exercise all the features
    so I can be confident it is working as expected

    Scenario: Populate the AWS environment to exercise CloudPatrol's features
        When I prepare the AWS environment for CloudPatrol testing
        And I create CloudFormation stacks 
        And I create IAM users without MFAs
        And I create IAM users with MFAs
        And I create IAM users that start with _
        And I create EC2 instances
        And I create EC2 instances with termination protection
        And I create Elastic IPs unassigned to EC2 instances
        And I create Elastic IPs assigned to EC2 instances
        And I add ports to default security group
        And I add security groups unassigned to any EC2 instances
        And I add security groups assigned to EC2 instances
        And I create OpsWorks stacks with layers, instances, and apps

