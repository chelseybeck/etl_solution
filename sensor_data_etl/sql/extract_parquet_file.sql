LOAD DATA OVERWRITE storied-storm-353916.raw_sensor_data.sensor_data
FROM FILES (
  format = 'PARQUET',
  uris = ['gs://sensor_data_files/sample.parquet']);