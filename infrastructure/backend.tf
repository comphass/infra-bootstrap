# terraform {
#   backend "s3" {
#     bucket         = "comphass-terraform-state-backend-lab"
#     key            = "terraform.tfstate"
#     region         = "eu-east-1"
#     dynamodb_table = "terraform_state"
#   }
# }