WITH cast_types AS
(SELECT DISTINCT 
CAST(time AS TIMESTAMP) AS time,
CAST(value AS FLOAT64) AS value,
TRIM(CAST(field AS STRING)) AS field,
TRIM(CAST(robot_id AS STRING)) AS robot_id,
CAST(run_uuid AS NUMERIC) AS run_uuid,
TRIM(CAST(sensor_type AS STRING)) AS sensor_type
FROM {{ params.raw_table_location }}),

recast AS 
(SELECT
time,
value,
field,
robot_id,
CAST(run_uuid AS STRING) AS run_uuid, --needs to be cast again to get into string format
sensor_type
FROM cast_types)

SELECT 
*, 
TO_HEX(SHA256(to_json_STRING(STRUCT(
  time, value, field, robot_id, sensor_type, run_uuid
)))) AS record_hash_code, -- create unique identifier
CURRENT_TIMESTAMP AS etl_update_ts
FROM recast