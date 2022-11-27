# resource "aws_s3_bucket" "terraform_state" {
#   bucket = "dapteoo-terraform-bucket-1"
# }

# resource "aws_s3_bucket_versioning" "bucket_versioning" {
#   bucket = aws_s3_bucket.terraform_state.id
#   versioning_configuration {
#     status = "Enabled"
#   }
# }

# resource "aws_s3_bucket_server_side_encryption_configuration" "example" {
#   bucket = aws_s3_bucket.terraform_state.bucket
#   rule {
#     apply_server_side_encryption_by_default {
#       sse_algorithm = "AES256"
#     }
#   }
# }

# # resource "aws_dynamodb_table" "terraform_locks" {
# #   name         = "terraform-locks"
# #   billing_mode = "PAY_PER_REQUEST"
# #   hash_key     = "LockID"
# #   attribute {
# #     name = "LockID"
# #     type = "S"
# #   }
# # }