// Backend
terraform {
  backend "gcs" {
    prefix = "terraform/state"
    bucket = "storied-storm-tf-state"
  }
}

module "etl-infra" {
  source = "./modules/etl-infra"
}

module "composer" {
  source = "./modules/composer"
}
