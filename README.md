# Wordpress HA deployment

The goal of this project is to automate a Wordpress infrastructure deployment.

## Requirements

- Highly available architecture;
- Wordpress must be able to scale horizontally;
- The infrastructure provisioning must be automated;
- It must be deployed to AWS.

## Tools

[Terraform](https://www.terraform.io/) will be used to describe and deploy the infrastructure.

## Architecture

### VPC
In the VPC, we will create one private subnet and one public subnet for each AZ.
This will allow us to create a multi-az deployment to reach our HA deployment requirement.
The application and the database instances will be deployed in the private subnets.
A NAT Gateway will be deployed in each public subnet. The outgoing internet traffic from the private instances will pass through the NAT Gateway.
The goal of this is to reduce the attack surface.

### Bastion
It will be deployed an EC2 instance in the first public subnet.
This will allow us to access the private subnet components from the internet.
We need to generate a new ssh key-pair for our bastion with `ssh-keygen -f bastion_key` command.

Keep in mind that in order to be more secure, we could create a security policy that whitelist our IP.
