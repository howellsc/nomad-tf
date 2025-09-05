resource "google_compute_firewall" "http" {

  allow {
    ports = [
      "80",
      "443"
    ]
    protocol = "tcp"
  }

  direction = "INGRESS"
  name      = "howells-network-http"
  network   = "howells-network"
  priority  = 1000
  source_ranges = [
    "0.0.0.0/0"
  ]
  target_tags = [
    "allow-http-80-443-ingress"
  ]
  source_tags = []

  lifecycle {
    replace_triggered_by = [google_compute_network.vpc]
  }
}

resource "google_compute_firewall" "ssh" {
  allow {
    ports = [
      "22",
    ]
    protocol = "tcp"
  }

  direction = "INGRESS"
  name      = "howells-network-ssh"
  network   = "howells-network"
  priority  = 1000
  source_ranges = [
    "0.0.0.0/0"
  ]
  target_tags = [
    "allow-tcp-22-ingress"
  ]
  source_tags = []

  lifecycle {
    replace_triggered_by = [google_compute_network.vpc]
  }
}

resource "google_compute_firewall" "allow_nomad_ui" {
  name    = "howells-network-nomad-ui"
  network = "howells-network"

  allow {
    protocol = "tcp"
    ports = ["4646"]
  }

  target_tags = ["nomad"]
  source_ranges = ["0.0.0.0/0"]
  direction = "INGRESS"

  lifecycle {
    replace_triggered_by = [google_compute_network.vpc]
  }
}

resource "google_compute_firewall" "allow_nomad_cluster" {
  name    = "howells-network-nomad-cluster"
  network = "howells-network"

  allow {
    protocol = "tcp"
    ports = ["4646", "4647", "4648"] # Add more if needed
  }

  allow {
    protocol = "udp"
    ports = ["4648"] # Serf gossip uses UDP
  }

  source_ranges = ["10.132.0.0/20"] # Adjust to your VPC CIDR
  target_tags = ["nomad"]

  lifecycle {
    replace_triggered_by = [google_compute_network.vpc]
  }
}

resource "google_compute_firewall" "egress" {
  allow {
    ports = [
      "80",
      "443"
    ]
    protocol = "tcp"
  }

  direction = "EGRESS"
  name      = "howells-network-http-egress"
  network   = "howells-network"
  priority  = 1000
  destination_ranges = [
    "0.0.0.0/0"
  ]
  target_tags = ["allow-http-80-443-egress"]
  source_tags = []

  lifecycle {
    replace_triggered_by = [google_compute_network.vpc]
  }
}