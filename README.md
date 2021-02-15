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

### RDS
Wordpress needs a MySQL database to work.
We will create the instance using AWS RDS. An AWS managed service that provides relational databases.
This will simplify the database setup and manageability.

### Wordpress instances
Since we need to scale horizontally, we will use an AWS Autoscaling Group.
We will define the Launch Configuration that will provision an EC2 with Wordpress installed and connected to the database.
To install and configure Wordpress there's the [userdata script](scripts/wordpress_setup.sh) which requires the database variables. The script will be used as a template file by Terraform, that will set all the database variables up.
Also in this case in order to access each EC2 instance we will use a new SSH key-pair.
We can generate it with the `ssh-keygen -f wp_key` command.

### Load Balancer
In order to expose Wordpress to the world we will use an AWS ELB.
In particular we will setup an Application Load Balancer.
The ALB allow us to work in the L7 of the ISO/OSI model, in our case in HTTP/HTTPS.
At the moment, the ALB will listen to the port 80 (HTTP) and forward the traffic to a random Wordpress EC2 instance.

## Configure and deploy
First of all check the [variables](variables.tf) and change them as you want.
You should create an S3 bucket on your AWS account and specify it in the [main.terraform.backend](main.tf).

You can use the following commands:
- `make init`: initialize terraform;
- `make plan`: checks the terraform manifests and executes the terraform plan;
- `make apply`: deploys the infrastructure to AWS;
- `make destroy`: destroys the infrastructure on AWS.
