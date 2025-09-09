resource "google_compute_network" "vpc" {
  name                    = "${var.name}-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet_us-west2" {
  name          = "subnet-us-west2"
  region        = var.region
  ip_cidr_range = "10.132.0.0/20"

  private_ip_google_access = true

  network = google_compute_network.vpc.id

  lifecycle {
    create_before_destroy = false
    replace_triggered_by = [google_compute_network.vpc]
  }
}
