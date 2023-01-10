LOAD DATA INTO 'storied-storm-353916.raw_sensor_data_prod.sensor_data'
FROM FILES (
  format = 'PARQUET',
  uris = ['gs://sensor_data_ingestion/sample.parquet']);