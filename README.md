# Terraform Example Repo

This repo is an example of how to structure your terraform repo to make
use of Terraform workspaces. It also provides examples of how to create
and test Terraform modules.

## Terraform Repo Principals

This repository structure is based on a couple of key principals.

1. Each Terraform repo should control a single project maximum. This could be a single application
or several applications that make up a single project maintained by a single team. You can go
more narrow if you want to, but expanding the scope of control can lead to teams stepping on
each others toes.
2. Use Terraform workspaces to model out your environments. Terraform's recommended practices say that
the best approach is to use one workspace for each environment of a given infrastructure component [link](https://www.terraform.io/docs/cloud/guides/recommended-practices/part1.html#the-recommended-terraform-workspace-structure).
3. Separate your core infrastructure from your application infrastructure. This makes it easier to model out your workspaces.
For example, you might have a single VPC per account instead of a VPC per application environment. I also am not going to be making frequent
changes to my VPC like I will be to my application infrastructure.

## Repo Structure Explained

For this example I have an AWS environment for a particular project that consists of two AWS accounts, a prod and a non-prod account. My applications have one production
environment (prd) which will be deployed in the prod account and two non-prod environments (dev & stg) which will be deployed in the non-prod account. The applications will
also exist in both the us-east-1 and us-east-2 regions.

### meta

This folder only exists to provide a environment to account mapping that is imported by the other workspaces. This could also be managed in a seperate repository.

### app-infrastructure

This folder contains your application specific infrastructure (ECS services, ALBs, etc). In order to be able to easily find
infrastructure related to a specific application I like to create a .tf file for each application which contains all of the infrastructure for that
specific app. If I have any shared infrastructure (like an ECS cluster) I'll put that in a service specific .tf file (ecs.tf in this case).

#### workspaces

In the `app-infrastructure` folder I create a workspace for each application environment. In my case an application environment consists of environment + region, so I will end up with
6 workspaces.

- prd-useast1
- prd-useast2
- dev-useast1
- dev-useast2
- stg-useast1
- stg-useast2

### core-infrastructure

This folder contains your core infrastructure that is needed for your applications to run, but is not specific to a particular application or environment. These could be
things like VPCs, Route53 Zones, some IAM roles, etc. These are things you would only create once per account or once per region. This will also depend a little on how you
model your infrastructure. For example, if you create a VPC per environment then you could move the VPC to the `app-infrastructure` folder.

#### workspaces

In the `core-infrastructure` folder I create a workspace for each region in each account. Since I am only deploying in two accounts and two regions I will end up with 4 workspaces.

- prd-useast1
- prd-useast2
- nonprd-useast1
- nonprd-useast2

## Modules

To keep everything in one place for this example repo I've included the modules as local modules, but you would not want to do this
in a real scenario. You would want to create separate repos for each module so that each module is version controled separately
and can be tagged with releases which you can then refernce in your module invocation.

In terms of module structure I have followed the recommended approach given by Hashicorp [here](https://www.terraform.io/docs/modules/index.html).

In terms of module philosophy there are a couple of tenants that I follow.

- _Modules should be abstracted to be easy and safe to use._ I follow an approach laid out by Segment in their talk [Terraform Abstractions for Safety and Power](https://youtu.be/IeweKUdHJc4). A very simple example of this would be to create a S3 bucket module
that sets the acl to private and applies a default server side encryption configuration. A more complex example would be what I am doing in the `ecs_service` module.
Rather than require the engineer to know which VPC and Subnets the Fargate service should be created in (which could also lead to dangerous misconfigurations, i.e. public subnets) I don't even present that as an option to the consumer of the module. Based on tags on the VPC resources I import the subnet information for the app
tier subnets and automatically use those. This approach 

- _Modules should be narrow in scope_. You should think of modules as building blocks that you can combine in different ways to create different architectures. If
you are starting out and need to create ECS services it might be tempting to create a single module that contains resources for your ECS Service, ALB, Target Group, Route53, etc. As you go on though you might decide you want to use a NLB with your ECS service or no load balancer. Of you might want to use an ALB with your Lambda
Function. You'll either find yourself managing 4 different modules with an ALB resource or you'll start breaking out the resources into their own modules which you can then combine.

- _Manage your modules like any other code_. By this I mean have a structured approach to managing your modules. Have detailed documentation, require pull requests
for updates, perform CI, and stick to a tagging strateg (i.e. [semver](https://semver.org/)). The section below talks about testing modules using [Terratest](https://github.com/gruntwork-io/terratest).

### Testing

In order to test Terraform I use [Terratest](https://github.com/gruntwork-io/terratest). This is an awesome project that lets you write Go tests which will provision your Terraform as real infrastructure in your AWS account, perform any tests against the infrastructure, and then tear down the infrastructure. For example, I
have a test in this repo that provisions an ECS service behind an ALB, gets the DNS of the ALB, makes a GET request, and validates that the response and response
code is what is expected.

The structure of my tests were taken from the [Hashicorp Vault Terraform module](https://github.com/hashicorp/terraform-aws-vault/tree/master/test). If you want to
see some really good examples of what you can do with Terratest check out that repo.
