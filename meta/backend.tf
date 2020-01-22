/**
* I am using s3 access points to access a state bucket in a central AWS account.
* Access points use the format of access_point_name-account_id.s3-accesspoint.Region.amazonaws.com.
* In order to get the s3 backend to work with access points you need to set the bucket equal to the 
* access_point_name-account_id value and the endpoint equal to the s3-accesspoint.Region.amazonaws.com value
*/
terraform {
  backend "s3" {
    bucket   = ""
    endpoint = ""
    key      = "terraform-example/meta/terraform.tfstate"
    region   = "us-east-2"
  }
}
