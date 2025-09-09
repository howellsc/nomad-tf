provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

terraform {
  backend "local" {}
}

module "gce_instances" {
  source = "./modules/instances"

  project_id      = var.project_id
  region          = var.region
  vpc_name        = module.vpc_network.vpc_name
  vpc_subnet_name = module.vpc_network.vpc_subnet_us1_name
  name            = var.name
}

module "vpc_network" {
  source = "./modules/vpc"

  region = var.region
  name   = var.name
}
