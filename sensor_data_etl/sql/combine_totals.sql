-- join worktables and total calculated values
SELECT 
  v.time,
  v.vx_1,
  v.vy_1,
  v.vz_1,
  v.vx_2,
  v.vy_2,
  v.vz_2,
  a.ax_1,
  a.ay_1,
  a.az_1,
  a.ax_2,
  a.ay_2,
  a.az_2,
  (vx_1 + vy_1 + vz_1) AS v1,
  (vx_2 + vy_2 + vz_2) AS v2,
  (ax_1 + ay_1 + az_1) AS a1,
  (ax_2 + ay_2 + az_2) AS a2,
  (ABS(fx_1) + ABS(fy_1) + ABS(fz_1)) AS f1,
  (ABS(fx_2) + ABS(fy_2) + ABS(fz_2)) AS f2,
  v.run_uuid,
  v.trns_record_hash_code,
  CURRENT_TIMESTAMP() AS etl_update_ts
  FROM
    {{ params.acceleration_table }} a
  INNER JOIN
    {{ params.velocity_table }} v
  ON
    a.trns_record_hash_code = v.trns_record_hash_code
  INNER JOIN
    {{ params.base_table}} b
  ON
    a.trns_record_hash_code = b.trns_record_hash_code
  ORDER BY
    time