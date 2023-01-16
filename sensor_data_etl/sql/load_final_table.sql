-- changes order of columns and creates a 
-- unique identifier for transformed rows
SELECT  
time,
fx_1,
fx_2,
fy_1,
fy_2,
fz_1,
fz_2,
x_1,
x_2,
y_1,
y_2,
z_1,
z_2,
TO_HEX(SHA256(TO_JSON_STRING(STRUCT( time,
          fx_1,
          fx_2,
          fy_1,
          fy_2,
          fz_1,
          fz_2,
          x_1,
          x_2,
          y_1,
          y_2,
          z_1,
          z_2, 
          run_uuid )))) AS trns_record_hash_code,
  -- creates unique identifier
CURRENT_TIMESTAMP AS etl_update_ts,
run_uuid
FROM {{ params.source_table }}