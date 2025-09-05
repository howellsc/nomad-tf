resource "google_compute_router" "nat_router" {
  name    = "howells-nat-router"
  network = google_compute_network.vpc.id
  region  = var.region

  lifecycle {
    replace_triggered_by = [google_compute_network.vpc]
  }
}

resource "google_compute_router_nat" "nat" {
  name   = "howells-nat"
  router = google_compute_router.nat_router.name
  region = var.region

  nat_ip_allocate_option = "AUTO_ONLY" # Automatically allocates public IPs for NAT.

  # Define the subnets that will use NAT (all subnets in the VPC).
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  depends_on = [google_compute_router.nat_router]
}