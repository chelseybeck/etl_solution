SELECT * EXCEPT (field, robot_id, sensor_type) 
FROM 
(
  SELECT
  time,
  value, 
  field,
  CONCAT(field, '_', robot_id) AS new_field,
  robot_id,
  sensor_type,
  run_uuid,
  raw_record_hash_code,
  CURRENT_TIMESTAMP AS etl_update_ts
  FROM {{ params.source_table }}
)
PIVOT
(
  ANY_VALUE(value)
  FOR new_field in ('fx_1', 'fx_2', 'fy_1', 'fy_2', 'fz_1', 'fz_2', 'x_1', 'x_2', 'y_1', 'y_2', 'z_1', 'z_2')
)