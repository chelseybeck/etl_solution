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
record_hash_code,
etl_update_ts,
run_uuid
FROM {{ params.source_table }}