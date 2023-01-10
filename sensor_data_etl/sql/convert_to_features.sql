SELECT * EXCEPT (field) 
FROM 
(
  SELECT
  time,
  value, 
  field,
  CONCAT(field, '_', robot_id) AS new_field,
  robot_id,
  sensor_type,
  record_hash_code,
  etl_update_ts
  FROM {{ params.clean_table_location }}
)
PIVOT
(
  ANY_VALUE(value)
  FOR new_field in ('fx_1', 'fx_2', 'fy_1', 'fy_2', 'fz_1', 'fz_2', 'x_1', 'x_2', 'y_1', 'y_2', 'z_1', 'z_2')
)