// Create bucket to store parquet files(s) for ingestion
resource "google_storage_bucket" "etl_extraction_bucket" {
  name                        = "sensor_data_files"
  project                     = var.project_id
  location                    = "US"
  uniform_bucket_level_access = true
}

// Create dataset for ingestion to raw layer
resource "google_bigquery_dataset" "raw_dataset" {
  dataset_id  = "raw_sensor_data_prod"
  project     = var.project_id
  description = "This dataset contains raw robot sensor data - not ready for consumption"
  location    = "US"

  access {
    role          = "OWNER"
    user_by_email = ""
  }

  access {
    role          = "OWNER"
    user_by_email = ""
  }
}

// Create dataset for transformation layer
resource "google_bigquery_dataset" "trns_dataset" {
  dataset_id  = "trns_sensor_data_prod"
  project     = var.project_id
  description = "This dataset contains transformed robot sensory data - ready for consumption"
  location    = "US"

  access {
    role          = "OWNER"
    user_by_email = var.service_account
  }

  access {
    role          = "OWNER"
    user_by_email = var.user_email 
  }
}

// Create dataset for staging layer
resource "google_bigquery_dataset" "staging_dataset" {
  dataset_id  = "w_sensor_data_prod"
  project     = var.project_id
  description = "This dataset contains temporary work (staging) tables that aid in transformation"
  location    = "US"

  access {
    role          = "OWNER"
    user_by_email = var.service_account 
  }

  access {
    role          = "OWNER"
    user_by_email = var.user_email 
  }
}