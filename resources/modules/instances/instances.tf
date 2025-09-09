# Create the service account
resource "google_service_account" "vm_sa" {
  project      = var.project_id
  account_id   = "${var.name}-vm-service-account"
  display_name = "VM Service Account"
}

resource "google_storage_bucket" "startup_scripts" {
  name                        = "${var.name}-${var.project_id}-startup-scripts"
  location                    = var.region
  force_destroy               = true
  uniform_bucket_level_access = true
}

resource "google_storage_bucket_object" "nomad_script" {
  name   = "nomad-dev.sh"
  bucket = google_storage_bucket.startup_scripts.name
  source = "${path.module}/startup-scripts/nomad-dev.sh"
}

resource "google_project_iam_member" "vm_storage_access" {
  project = var.project_id
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${google_service_account.vm_sa.email}"
}

resource "google_project_iam_member" "vm_compute_access" {
  project = var.project_id
  role    = "roles/compute.viewer"
  member  = "serviceAccount:${google_service_account.vm_sa.email}"
}

resource "google_compute_instance_template" "gce_nomad_template" {

  disk {
    source_image = "ubuntu-os-cloud/ubuntu-2204-lts"
    auto_delete  = true
    boot         = true
    type         = "PERSISTENT"
    disk_size_gb = 10
  }

  region = var.region

  machine_type = "e2-micro"
  name         = "${var.name}-dev-micro-nomad"

  network_interface {
    network    = var.vpc_name
    subnetwork = var.vpc_subnet_name
  }

  labels = {
    "organisation" = var.name
    "type"         = "nomad"
    "purpose"      = "container-orchestration"
  }

  tags = ["allow-tcp-22-ingress", "allow-http-80-443-egress", "nomad"]

  service_account {
    email  = google_service_account.vm_sa.email
    scopes = []
  }

  metadata = {
    "enable-osconfig"  = "TRUE"
    startup-script-url = "gs://${google_storage_bucket.startup_scripts.name}/nomad-dev.sh"
  }

  scheduling {
    provisioning_model = "STANDARD"
    preemptible        = false
  }

  # service_account {
  #   email = "92595832024-compute@developer.gserviceaccount.com"
  #   scopes = [
  #     "https://www.googleapis.com/auth/devstorage.read_only",
  #     "https://www.googleapis.com/auth/logging.write",
  #     "https://www.googleapis.com/auth/monitoring.write",
  #     "https://www.googleapis.com/auth/service.management.readonly",
  #     "https://www.googleapis.com/auth/servicecontrol",
  #     "https://www.googleapis.com/auth/trace.append",
  #     "https://www.googleapis.com/auth/cloud-platform"
  #   ]
  # }
}

resource "google_compute_region_instance_group_manager" "gce_nomad_mig" {
  name = "${var.name}-gce-nomad-mig"

  region             = var.region
  base_instance_name = "gce-nomad"
  version {
    instance_template = google_compute_instance_template.gce_nomad_template.id
  }
  target_size = 3 # Number of backend instances

  named_port {
    name = "http"
    port = 4646
  }

  auto_healing_policies {
    health_check      = google_compute_region_health_check.nomad_tcp.id
    initial_delay_sec = 600
  }

  lifecycle {
    replace_triggered_by = [google_compute_instance_template.gce_nomad_template]
  }

  depends_on = [google_compute_instance_template.gce_nomad_template]
}

resource "google_compute_region_backend_service" "gce_nomad_backend_service" {
  name     = "${var.name}-gce-backend-service"
  protocol = "HTTP"

  load_balancing_scheme = "EXTERNAL_MANAGED"

  backend {
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1
    group           = google_compute_region_instance_group_manager.gce_nomad_mig.instance_group
  }

  health_checks = [google_compute_region_health_check.nomad_tcp.id]

  port_name = "http" # Refer to the named port in the MIG (usually "http" or "https")

  depends_on = [google_compute_region_instance_group_manager.gce_nomad_mig]
}

resource "google_os_config_patch_deployment" "patch" {
  patch_deployment_id = "${var.name}-patch-deploy"

  instance_filter {
    all = true
  }

  recurring_schedule {
    time_zone {
      id = "Europe/London"
    }

    time_of_day {
      hours   = 0
      minutes = 0
      seconds = 0
      nanos   = 0
    }
  }
}

resource "google_compute_region_health_check" "nomad_tcp" {
  name                = "${var.name}-nomad-tcp-health-check"
  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 3
  region              = var.region

  tcp_health_check {
    port = 4646
  }
}
