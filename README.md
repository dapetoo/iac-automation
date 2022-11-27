# AUTOMATE INFRASTRUCTURE WITH IAC USING TERRAFORM. PART 4 – TERRAFORM CLOUD

Terraform Cloud is a managed service that provides you with Terraform CLI to provision infrastructure, either on demand or in response to various events.

Terraform Cloud executes Terraform commands on disposable virtual machines, this remote execution is also called remote operations.

**Migrate your .tf codes to Terraform Cloud**

Create a Terraform Cloud account and verify your email to get started.

Create an organization, Select "Start from scratch", choose a name for your organization and create it.

Configure a workspace, select **version control workflow** and you will be promped to connect your GitHub account to your workspace – follow the prompt and add your newly created repository to the workspace.

Follow the instruction to configure your project and add the variables in the terraform.tfvars file and also configure AWS ACCESS KEY and AWS SECRET KEY to authenticate Terraform cloud with your AWS account.

Run plan and apply from the UI to provision infrastructure with Terraform cloud


#### Software Requirements

Install Packer and Ansible

Packer is a free and open source tool for creating golden images for multiple platforms from a single source configuration.

Ansible is a suite of software tools that enables infrastructure as code. It is open-source and the suite includes software provisioning, configuration management, and application deployment functionality.

```
sudo apt update
sudo apt install -y ansible

#Using Python
python3 -m pip install --user ansible

##Packer installation

curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install packer
```

Build AMI using Packer

bastion.pkr.hcl

```
packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "region" {
  type    = string
  default = "us-east-1"
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

# source blocks are generated from your builders; a source can be referenced in
# build blocks. A build block runs provisioners and post-processors on a
# source.
source "amazon-ebs" "terraform-bastion-prj-19" {

  ami_name      = "terraform-bastion-prj-19-${local.timestamp}"
  instance_type = "t2.micro"
  region        = var.region

  source_ami_filter {
    filters = {
      name                = "RHEL-8.2.0_HVM-20210907-x86_64-0-Hourly2-GP2"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["309956199498"]
  }
  ssh_username = "ec2-user"
  tag {
    key   = "Name"
    value = "terraform-bastion-prj-19"
  }
}

# a build block invokes sources and runs provisioning steps on them.
build {
  sources = ["source.amazon-ebs.terraform-bastion-prj-19"]

  provisioner "shell" {
    script = "bastion.sh"
  }
}
```

bastion.sh file
```
# user data for bastion

#!/bin/bash
sudo yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
sudo yum install -y dnf-utils http://rpms.remirepo.net/enterprise/remi-release-8.rpm 
sudo yum install -y mysql-server wget vim telnet htop git python3 net-tools zip
sudo systemctl start chronyd
sudo systemctl enable chronyd


#installing java 11
sudo yum install -y java-11-openjdk-devel
sudo echo "export JAVA_HOME=$(dirname $(dirname $(readlink $(readlink $(which javac)))))" >> ~/.bash_profile
sudo echo "export PATH=$PATH:$JAVA_HOME/bin" >> ~/.bash_profile
sudo echo "export CLASSPATH=.:$JAVA_HOME/jre/lib:$JAVA_HOME/lib:$JAVA_HOME/lib/tools.jar" >> ~/.bash_profile
source ~/.bash_profile

# clone the Ansible repo
git clone https://github.com/darey-devops/PBL-project-19.git


# install botocore, ansible and awscli
sudo python3 -m pip install boto
sudo python3 -m pip install boto3
sudo python3 -m pip install PyMySQL
sudo python3 -m pip install mysql-connector-python
sudo python3 -m pip install --upgrade setuptools
sudo python3 -m pip install --upgrade pip
sudo python3 -m pip install psycopg2==2.7.5 --ignore-installed
sudo curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo unzip awscliv2.zip
sudo ./aws/install
sudo yum install ansible -y
sudo yum install -y policycoreutils-python-utils
ansible-galaxy collection install amazon.aws
ansible-galaxy collection install community.general
ansible-galaxy collection install community.mysql
ansible-galaxy collection install community.postgresql

```

Initialize and build AMI using packer
```
packer init bastion.pkr.hcl 
packer init nginx.pkr.hcl 
packer init ubuntu.pkr.hcl
packer init web.pkr.hcl

packer build bastion.pkr.hcl 
packer build nginx.pkr.hcl 
packer build ubuntu.pkr.hcl 
packer build web.pkr.hcl
```

Using Ansible tool to configure the project

We are using Ansible dynamic inventory 

aws_ec2.yml file

```
plugin: amazon.aws.aws_ec2
aws_profile: default

regions:
  - "us-east-1"

strict: False

keyed_groups:
- key: tags
  prefix: tag

filters:
  tag:Name:
    - ACS-bastion
    - ACS-nginx
    - ACS-tooling
    - ACS-wordpress
  instance-state-name : running
  
hostnames:
# a list in order of precedence for hostname variables.
  - private-ip-address
  - tag:Name
  - dns-name
  - ip-address

compose:
  ansible_host: private_ip_address
```

Run the playbook

From the Bastion server, configure AWS ACCESS KEY and AWS SECRET KEY to be able to configure EC2 instances

```
ansible-playbook  playbooks/site.yml -i inventory/aws_ec2.yml
```


### Project Screenshots

![Project Screenshots](https://github.com/dapetoo/iac-automation/blob/terraform-cloud/screenshots/01.png)
![Project Screenshots](https://github.com/dapetoo/iac-automation/blob/terraform-cloud/screenshots/02.png)
![Project Screenshots](https://github.com/dapetoo/iac-automation/blob/terraform-cloud/screenshots/03.png)
![Project Screenshots](https://github.com/dapetoo/iac-automation/blob/terraform-cloud/screenshots/04.png)
![Project Screenshots](https://github.com/dapetoo/iac-automation/blob/terraform-cloud/screenshots/05.png)
![Project Screenshots](https://github.com/dapetoo/iac-automation/blob/terraform-cloud/screenshots/06.png)
![Project Screenshots](https://github.com/dapetoo/iac-automation/blob/terraform-cloud/screenshots/07.png)
![Project Screenshots](https://github.com/dapetoo/iac-automation/blob/terraform-cloud/screenshots/08.png)
![Project Screenshots](https://github.com/dapetoo/iac-automation/blob/terraform-cloud/screenshots/09.png)
![Project Screenshots](https://github.com/dapetoo/iac-automation/blob/terraform-cloud/screenshots/10.png)
![Project Screenshots](https://github.com/dapetoo/iac-automation/blob/terraform-cloud/screenshots/11.png)
![Project Screenshots](https://github.com/dapetoo/iac-automation/blob/terraform-cloud/screenshots/12.png)
![Project Screenshots](https://github.com/dapetoo/iac-automation/blob/terraform-cloud/screenshots/13.png)
![Project Screenshots](https://github.com/dapetoo/iac-automation/blob/terraform-cloud/screenshots/14.png)
![Project Screenshots](https://github.com/dapetoo/iac-automation/blob/terraform-cloud/screenshots/15.png)
![Project Screenshots](https://github.com/dapetoo/iac-automation/blob/terraform-cloud/screenshots/16.png)
![Project Screenshots](https://github.com/dapetoo/iac-automation/blob/terraform-cloud/screenshots/17.png)
