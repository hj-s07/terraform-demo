terraform {
 backend "s3" {
   bucket = "terraform-ssg-wl"
   key = "workspaces-example2/terraform.tfstate"
   region = "ap-northeast-2"
   dynamodb_table = "terraform-locks"
   encrypt = true
 }
}