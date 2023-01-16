  -- trim whitespace and convert to target datatypes
SELECT
  DISTINCT CAST(time AS TIMESTAMP) AS time,
  CAST(value AS FLOAT64) AS value,
  TRIM(CAST(field AS STRING)) AS field,
  TRIM(CAST(robot_id AS STRING)) AS robot_id,
  CAST(CAST(run_uuid AS NUMERIC) AS STRING) AS run_uuid,
  TRIM(CAST(sensor_type AS STRING)) AS sensor_type,
  TO_HEX(SHA256(TO_JSON_STRING(STRUCT( time,
          value,
          field,
          robot_id,
          sensor_type,
          run_uuid )))) AS raw_record_hash_code,
  -- create unique identifier
  CURRENT_TIMESTAMP AS etl_update_ts
FROM {{ params.source_table }}