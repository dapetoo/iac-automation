# AUTOMATE INFRASTRUCTURE WITH IAC USING TERRAFORM. PART 3 – REFACTORING

## Purpose of Backend

By default, Terraform uses a backend called local , which stores state as a local file on disk. A backend defines where Terraform stores its state data files.

Terraform uses persisted state data to keep track of the resources it manages. Most non-trivial Terraform configurations either integrate with Terraform Cloud or use a backend to store state remotely. This lets multiple people access the state data and work together on that collection of infrastructure resources.

Backend block
```
terraform {
  backend "remote" {
    organization = "example_corp"

    workspaces {
      name = "my-app-prod"
    }
  }
}
```

Using S3 as a backend

```bash
resource "aws_s3_bucket" "terraform_state" {
  bucket = "dapteoo-terraform-bucket-1"
}

resource "aws_s3_bucket_versioning" "bucket_versioning" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "example" {
  bucket = aws_s3_bucket.terraform_state.bucket
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}
```

Using the configuration above, we need to initialize "terraform init" to use the configuration as the backend configuration. 

```
 terraform {
   backend "s3" {
     bucket = "dapteoo-terraform-bucket-1"
     key    = "global/s3/terraform.tfstate"
     region = "us-east-1"
     # dynamodb_table = "terraform-locks"
     encrypt = true
   }
 }
```

```bash
terraform init
```

**Using Terraform workspaces**

Terraform workspaces are a feature that lets you isolate your infrastructure resources from each other. This is useful when you’re working on multiple versions of your infrastructure at the same time, such as when you’re running tests in a staging environment.

Each Terraform configuration has an associated backend that defines how Terraform executes operations and where Terraform stores persistent data, like state.

The persistent data stored in the backend belongs to a workspace. The backend initially has only one workspace containing one Terraform state associated with that configuration. Some backends support multiple named workspaces, allowing multiple states to be associated with a single configuration. The configuration still has only one backend, but you can deploy multiple distinct instances of that configuration without configuring a new backend or changing authentication credentials.


**Terraform Modules**

Modules are containers for multiple resources that are used together. A module consists of a collection of .tf and/or .tf.json files kept together in a directory.

Modules are the main way to package and reuse resource configurations with Terraform.

The Root Module
Every Terraform configuration has at least one module, known as its root module, which consists of the resources defined in the .tf files in the main working directory.

Child Modules
A Terraform module (usually the root module of a configuration) can call other modules to include their resources into the configuration. A module that has been called by another module is often referred to as a child module.

Child modules can be called multiple times within the same configuration, and multiple configurations can use the same child module.

Published Modules
In addition to modules from the local filesystem, Terraform can load modules from a public or private registry. This makes it possible to publish modules for others to use, and to use modules that others have published.

The Terraform Registry hosts a broad collection of publicly available Terraform modules for configuring many kinds of common infrastructure. These modules are free to use, and Terraform can download them automatically if you specify the appropriate source and version in a module call block.


Using Modules
Module Blocks documents the syntax for calling a child module from a parent module, including meta-arguments like for_each.

Module Sources documents what kinds of paths, addresses, and URIs can be used in the source argument of a module block.

The Meta-Arguments section documents special arguments that can be used with every module, including providers, depends_on, count, and for_each.

**Project Refactoring**

Break down your Terraform codes to have all resources in their respective modules. Combine resources of a similar type into directories within a ‘modules’ directory, for example, like this:


- modules
  - ALB: For Apllication Load balancer and similar resources
  - EFS: For Elastic file system resources
  - RDS: For Databases resources
  - Autoscaling: For Autosacling and launch template resources
  - compute: For EC2 and rlated resources
  - VPC: For VPC and netowrking resources such as subnets, roles, e.t.c.
  - security: for creating security group resources

Each module shall contain following files:

- main.tf (or %resource_name%.tf) file(s) with resources blocks
- outputs.tf (optional, if you need to refer outputs from any of these resources in your root module)
- variables.tf (as we learned before - it is a good practice not to hard code the values and use variables)


### Project Screenshots
![Project Screenshots](https://github.com/dapetoo/iac-automation/blob/refactoring/screenshots/01.png)
![Project Screenshots](https://github.com/dapetoo/iac-automation/blob/refactoring/screenshots/02.png)
![Project Screenshots](https://github.com/dapetoo/iac-automation/blob/refactoring/screenshots/03.png)
![Project Screenshots](https://github.com/dapetoo/iac-automation/blob/refactoring/screenshots/04.png)
![Project Screenshots](https://github.com/dapetoo/iac-automation/blob/refactoring/screenshots/05.png)
![Project Screenshots](https://github.com/dapetoo/iac-automation/blob/refactoring/screenshots/06.png)
![Project Screenshots](https://github.com/dapetoo/iac-automation/blob/refactoring/screenshots/07.png)
![Project Screenshots](https://github.com/dapetoo/iac-automation/blob/refactoring/screenshots/08.png)
![Project Screenshots](https://github.com/dapetoo/iac-automation/blob/refactoring/screenshots/09.png)
![Project Screenshots](https://github.com/dapetoo/iac-automation/blob/refactoring/screenshots/10.png)
![Project Screenshots](https://github.com/dapetoo/iac-automation/blob/refactoring/screenshots/11.png)
![Project Screenshots](https://github.com/dapetoo/iac-automation/blob/refactoring/screenshots/12.png)
![Project Screenshots](https://github.com/dapetoo/iac-automation/blob/refactoring/screenshots/13.png)
![Project Screenshots](https://github.com/dapetoo/iac-automation/blob/refactoring/screenshots/14.png)
![Project Screenshots](https://github.com/dapetoo/iac-automation/blob/refactoring/screenshots/15.png)
![Project Screenshots](https://github.com/dapetoo/iac-automation/blob/refactoring/screenshots/16.png)
![Project Screenshots](https://github.com/dapetoo/iac-automation/blob/refactoring/screenshots/17.png)
![Project Screenshots](https://github.com/dapetoo/iac-automation/blob/refactoring/screenshots/18.png)
![Project Screenshots](https://github.com/dapetoo/iac-automation/blob/refactoring/screenshots/19.png)
