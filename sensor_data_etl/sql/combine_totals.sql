-- join worktables and total calculated values
WITH
  totals AS (
  SELECT
    a.time,
    v.vx_1,
    v.total_vx_1,
    v.vy_1,
    v.total_vy_1,
    v.vz_1,
    v.total_vz_1,
    v.vx_2,
    v.total_vx_2,
    v.vy_2,
    v.total_vy_2,
    v.vz_2,
    v.total_vz_2,
    a.ax_1,
    a.total_ax_1,
    a.ay_1,
    a.total_ay_1,
    a.az_1,
    a.total_az_1,
    a.ax_2,
    a.total_ax_2,
    a.ay_2,
    a.total_ay_2,
    a.az_2,
    a.total_az_2,
    f.total_fx_1,
    f.total_fy_1,
    f.total_fz_1,
    f.total_fx_2,
    f.total_fy_2,
    f.total_fz_2,
    v.run_uuid
  FROM
    {{ params.acceleration_table }} a
  INNER JOIN
    {{ params.velocity_table }} v
  ON
    a.trns_record_hash_code = v.trns_record_hash_code
  INNER JOIN
    {{ params.force_table }} f
  ON
    a.trns_record_hash_code = f.trns_record_hash_code
  ORDER BY
    time)
SELECT
  time,
  vx_1,
  vy_1,
  vz_1,
  vx_2,
  vy_2,
  vz_2,
  ax_1,
  ay_1,
  az_1,
  ax_2,
  ay_2,
  az_2,
  (total_vx_1 + total_vy_1 + total_vz_1) AS v1,
  (total_vx_2 + total_vy_2 + total_vz_2) AS v2,
  (total_ax_1 + total_ay_1 + total_az_1) AS a1,
  (total_ax_2 + total_ay_2 + total_az_2) AS a2,
  (total_fx_1 + total_fy_1 + total_fz_1) AS f1,
  (total_fx_2 + total_fy_2 + total_fz_2) AS f2,
  run_uuid 
FROM
  totals 
ORDER BY
  time