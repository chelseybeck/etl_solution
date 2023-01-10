// Creates Composer cluster to run Airflow jobs
resource "google_composer_environment" "etl_composer_environment" {
  provider = google
  name = "sensor-data-prod"
  config {
    software_config {
      image_version = "composer-2.1.2-airflow-2.3.4"
    }
    environment_size = "ENVIRONMENT_SIZE_SMALL"
    node_config {
      service_account = var.service_account
    }
    workloads_config {
      scheduler {
        cpu        = 0.5
        memory_gb  = 1.875
        storage_gb = 1
        count      = 1
      }
      web_server {
        cpu        = 0.5
        memory_gb  = 1.875
        storage_gb = 1
      }
      worker {
        cpu = 0.5
        memory_gb  = 1.875
        storage_gb = 1
        min_count  = 1
        max_count  = 3
      }
    }
  }
}