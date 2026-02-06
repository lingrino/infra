module "s3_terraform_state" {
  source = "../../../../terraform-modules/s3//"

  name = "lingrino-prod-usw2-terraform-state"
}
