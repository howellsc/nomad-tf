resource "google_compute_firewall" "http" {

  allow {
    ports = [
      "80",
      "443"
    ]
    protocol = "tcp"
  }

  direction = "INGRESS"
  name      = "${var.name}-network-http"
  network   = google_compute_network.vpc.id
  priority  = 1000
  source_ranges = [
    google_compute_subnetwork.subnet_us-west2.ip_cidr_range
  ]
  target_tags = [
    "${var.name}-allow-http-80-443-ingress"
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
  name      = "${var.name}-network-ssh"
  network   = google_compute_network.vpc.id
  priority  = 1000
  source_ranges = [
    google_compute_subnetwork.subnet_us-west2.ip_cidr_range
  ]
  target_tags = [
    "${var.name}-allow-tcp-22-ingress"
  ]
  source_tags = []

  lifecycle {
    replace_triggered_by = [google_compute_network.vpc]
  }
}

resource "google_compute_firewall" "allow_nomad_ui" {
  name    = "${var.name}-network-nomad-ui"
  network = google_compute_network.vpc.id

  allow {
    protocol = "tcp"
    ports    = ["4646"]
  }

  target_tags = ["${var.name}-nomad"]
  source_ranges = [
    google_compute_subnetwork.subnet_us-west2.ip_cidr_range,
    "35.191.0.0/16",
    "130.211.0.0/22"
  ]
  direction = "INGRESS"

  lifecycle {
    replace_triggered_by = [google_compute_network.vpc]
  }
}

resource "google_compute_firewall" "allow_nomad_cluster" {
  name    = "${var.name}-network-nomad-cluster"
  network = google_compute_network.vpc.id

  allow {
    protocol = "tcp"
    ports    = ["4646", "4647", "4648"] # Add more if needed
  }

  allow {
    protocol = "udp"
    ports    = ["4648"] # Serf gossip uses UDP
  }

  source_ranges = [
    google_compute_subnetwork.subnet_us-west2.ip_cidr_range
  ]
  target_tags = ["${var.name}-nomad"]

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
  name      = "${var.name}-network-http-egress"
  network   = google_compute_network.vpc.id
  priority  = 1000
  destination_ranges = [
    google_compute_subnetwork.subnet_us-west2.ip_cidr_range
  ]
  target_tags = ["${var.name}-allow-http-80-443-egress"]
  source_tags = []

  lifecycle {
    replace_triggered_by = [google_compute_network.vpc]
  }
}

resource "google_compute_firewall" "allow_iap" {
  allow {
    ports = [
      "4646",
      "22"
    ]
    protocol = "tcp"
  }

  direction = "INGRESS"
  name      = "${var.name}-network-iap-ingress"
  network   = google_compute_network.vpc.id
  priority  = 999
  source_ranges = [
    "35.235.240.0/20"
  ]
  target_tags = ["${var.name}-iap-protected-vm"]
  source_tags = []

  lifecycle {
    replace_triggered_by = [google_compute_network.vpc]
  }
}
