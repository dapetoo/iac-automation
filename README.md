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

Using Terraform workspaces

