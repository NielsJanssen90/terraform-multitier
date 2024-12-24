# Terraform Multi-Tier FlaskApp
Contributor : Janssen Niels

### Caution: This manual is written for the windows operating system using Powershell as a terminal. 
For other operating systems, commands may differ. 

## 1. Table of Contents 

| Navigation |             
| :-------------------------------------------------  |
| [1. Table of Contents](#1-table-of-contents)             |
| [2. Overview](#2-overview)  |
| [3. Prerequisites](#3-prerequisites)                     |
| [4. Procedure](#4-procedure)       |
| [5. Execution](#5-execution)         |
| [6. Troubleshooting](#6-troubleshooting)         |


## 2. Overview

This terraform script will perform a fully automated deployment of a CRUD FlaskApp using AWS as a platform. the code of the WebApp can be found @ https://github.com/NielsJanssen90/FlaskApp. 

The diagram below is a representation of the architecture. 
It does not contain lines of the flow of data to prevet clutter, and the security groups are simplified on the diagram but all information can be derived from the terraform configuration files. 

![Diagram](images/diagram.png)

#### In the table below each file is displayed in chronological order. In the description tab there is a brief explanation of each file.

| **File**               | **Description**           | 
|------------------------|--------------------------|
| variables.tf          | This file contains all variables that are used in other .tf files. The use of this file is to allow for quick and easy changes to key variables. |
| vpc.tf                | Basic Virtual Private Cloud configuration               |
| security_groups.tf    | Configuration of all Security Groups               |
| secrets.tf            | Database Secrets key value pair: flaskapp_db_password creation. Couples the database username variable to a random 24 character password that can be retreived from the AWS Secrets Manager   |
| rds_subnet.tf         | Makes sure the RDS gets created in the correct subnet groups   |
| rds.tf                | Basic configuration of the Relational Database Service |
| ecr.tf                | Creation of the elastic container repository + automatisation of uploading docker image to repo  |
| loadbalancer.tf       | Creation of the Application Load Balancer and Target Groups | 
| ecs.tf                | Creation of the Elastic Container Service which will house the future containers (services / tasks) using Fargate (the serverless compute engine)|
| ecs_task_definition.tf | Configuration of the ECS Task Definition. The Task Definition is the blueprint of how ECS will run the container that will house the application. |
| ecs_service_flaskapp.tf | Configuration of the FlaskApp Service. This file brings everything together and will create the FlaskApp service using all previous configuration files. | 
| bastion.tf       | Creation of the bastion host + installation of mysqlclient/mariadbclient via user script | 

## 3. Prerequisites

| Application | URL |
|------------------------|--------------------------|
| Docker Engine             | https://docs.docker.com/desktop/setup/install/windows-install/    |
| AWS CLI                | https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html               |
| Dotenvx             | https://github.com/dotenvx/dotenvx    |
| OpenTofu                | https://opentofu.org/docs/intro/install/standalone/               |

## 4. Procedure

1. Install all of the software described in the prerequisites
2. Clone this repositories to your local machine
3. Fill in the .env file in your C:\Users\<your-user>\.aws\credentials
4. Fill in the .env file in the "terraform-multitier" repository folder
5. Extract arn from your LabRole and place it in the the variables.tf LabRole Variable
6. Generate the SSH keyfor the bastion host and edit the path in the variables.tf file
7. Run the terraform script

## 5. Execution

### Make sure to execute all steps in the prerequisites first.
#### The Docker engine service must be running for the terraform script to propperly function.  

##### Firstly, make sure to install all software that is described in the prerequisites. 

##### Secondly, clone the repository to the local machine. 
```
git clone https://gitlab.com/it-factory-thomas-more/cloud-engineering/24-25/r0930158/terraform-multitier.git
cd terraform-multitier
```

##### Thirdly, fill in the credentials and .env file located at: 

    - C:\Users\<your-user>\.aws\credentials
    - terraform\.env
 
You can find the information in your AWS account. 

example: 

```
[default]
aws_access_key_id=ASIAQ3EGUTXGGZN5SJMK
aws_secret_access_key=vooHq4/YzM9dSFnqddm8euIdGpPNSFVab+0iDcvR
aws_session_token=IQoJb3JpZ2luX2VjEKf//////////wEaCXVzLXdlc3QtMiJIMEYCIQCnsAMJ/1GRkAvWXQAERdEj1u6zC40vgyMfkui8Ex7rUwIhANgmXNxcwFLtydo/H/Vj0Uv9OjJzqNGTQywZP1wYqNDcKqcCCHAQABoMMDU4MjY0NDI3OTgwIgyAyuFPK57HUFK9eoIqhAK4EiCIq3zpF+tdBBPbOwqpE1xRUrVpsPVFfamJu5wQnxzMyNcSAUYhP619+LTj1sUClkAqkoMQ0b+Ey2dMpsVIm4ezX0tNg3wCri8HeJjMXZ+/qx+jRsm7JUVE4OEbM8DP0VsUvwWyzBnu79QTNVrnyUaefIX79SR2HPzqh3R4BJ3sU8YuLOXNppSaY30Goet1u530VAE8f4TmOv9IH/SEnLTM0WsqHX8WSq2uhBpoU+3TibitfpbwGiT7ToTfads3JJ09O2Cmwqhd7CqVMGnHRGiQ6R+qGia6JL/AL4vgrcC4wVlQwv3akTp4J4ENdTdhl+8lrudgetU75AlYhq71E6BHajCdjI+7BjqcAfQd+AUrNLw/7RAudb3/eyURwh2oPM6z41JeHqkVXq+Qfhaskb5sNzqvPF4XuM79R2Ra6KXJbU7MFpdO8S9IXQh5HvFTA3POSqRdmk4IEnX+ej/p1t71pVKhht//LnyAhxRwXUkvXwlgFnKMPUYCvj7xiZSt6fXpDNnJwR4zzYLHkGkRrqksMXcdSbmCtjX22D8mr0jZYtAFslPbPQ==
```

##### Now we can extract the LabRole from the AWS account using the AWS CLI. 

To do this execute the following command in the PowerShell terminal: 

```
aws iam get-role --role-name LabRole --query "Role.Arn" --output text
```

Enter this LabRole in the LabRole variable located in the "terraform-multitier\variables.tf" file. 

##### Now generate an SSH key for the bastion host and edit the path in the variables.tf file

Edit the following command based on your configuration and paste it in your terminal. 

```
ssh-keygen -t rsa -b 4096 -f C:\Users\<YourUsername>\.ssh\ssh-key-bastion
```

example: 

![Generate ssh key](images/generatessh.png)

Edit the path in the variables.tf file to the path on your local machine. 

##### Finally run the terraform script 

tofu init = downloads all necessary plugins, prepares the backend and ensures the environment is ready. 

tofu plan = Shows the current state and the future state. Displays a summary what changes will be made but won't apply anything yet.

tofu apply = Executes the plan generated by tofu plan. 

```
dotenvx run --- tofu init
dotenvx run --- tofu plan
dotenvx run --- tofu apply
```

#### The most important variables you will need are displayed after executing the terraform script. Use them to your advantage. 

example: 

![tofu apply complete](images/tfcomplete.png)

#### Beware, The bastion host will by default only allow the public ip address of the network the terraform script was ran on. 
##### If you want access from another network you will have to add the public ip address to the security group manually. 

The database will automatically be initialized but if you want to make changes to the database, you can use the bastion host for this. 

To connect to the bastion host, use the following command: 

```
ssh -i "C:\Users\<your_user_account>\.ssh\ssh-key-bastion" ec2-user@<bastion_host_public_ip>
```
In AWS go to the "Secrets Manager" and look for the Flaskapp-db-password Key value pair. Here you can find the Database password. 

Now you can connect to the database using the following command: 

#### Remove the port when connecting to the RDS endpoint

```
mysql -h <RDS_endpoint> -u <db_username> -p
```

example: 

![How to connect to the DB](images/dbconnect.png)


To surf to the flaskapp, paste the <alb_dns_name> in your browsers search bar. 

![How to surf to the FlaskApp](images/finalurl.png)

![The FlaskApp](images/workingsite.png)

## 6. Troubleshooting

##### Entrypoint.sh is missing 

In case you get an error that says the entrypoint.sh file is missing when running the terraform script, open the dockerfile & entrypoint.sh file in notepad++. 
Turn on "Display line endings" and make sure that every new line ends with LF (Line Feed)
This is required when using the Docker engine on Windows. 

example: 

![Notepad LF check](images/LF.png)


##### Docker engine error

In case you get errors regarding Docker, this probably means your docker engine is not running. 

![Docker error](images/dockererror.png)


##### Terminal not in sync with current .aws\\credentials

In some cases the terraform script will break and give an error similar as displayed in following screenshot. 
If you have this problem, simply start a new terminal in the correct directory for the credentials to refresh. 

![Credentials problem](images/credentials.png)




