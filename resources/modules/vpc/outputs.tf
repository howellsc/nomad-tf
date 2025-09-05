output "vpc_name" {
  value = google_compute_network.vpc.id
}

output "vpc_subnet_us1_name" {
  value = google_compute_subnetwork.subnet_us-west2.id
}