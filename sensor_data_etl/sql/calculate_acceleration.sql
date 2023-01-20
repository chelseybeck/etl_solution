WITH
  a_prev_values AS (
  SELECT
    trns_record_hash_code,
    time,
    run_uuid,
    -- find the value from the previous row in the window
    -- used for calculating change in velocity
    LAG(time) OVER win1 AS prev_time,
    vx_1,
    LAG(vx_1) OVER win1 AS vx_1_prev_value,
    vy_1,
    LAG(vy_1) OVER win1 AS vy_1_prev_value,
    vz_1,
    LAG(vz_1) OVER win1 AS vz_1_prev_value,
    vx_2,
    LAG(vx_2) OVER win1 AS vx_2_prev_value,
    vy_2,
    LAG(vy_2) OVER win1 AS vy_2_prev_value,
    vz_2,
    LAG(vz_2) OVER win1 AS vz_2_prev_value
  FROM
    `storied-storm-353916.w_sensor_data.w_velocity_calculated`
  WINDOW
    win1 AS (
    PARTITION BY
      run_uuid
    ORDER BY
      time )
  ORDER BY
    time ),
  a_changes AS(
  SELECT
    *,
    ABS(TIMESTAMP_DIFF(time, prev_time, MILLISECOND)) AS change_in_time,
    ABS(vx_1 - vx_1_prev_value) AS vx_1_change,
    ABS(vy_1 - vy_1_prev_value) AS vy_1_change,
    ABS(vz_1 - vz_1_prev_value) AS vz_1_change,
    ABS(vx_2 - vx_2_prev_value) AS vx_2_change,
    ABS(vy_2 - vy_2_prev_value) AS vy_2_change,
    ABS(vz_2 - vz_2_prev_value) AS vz_2_change,
  FROM
    a_prev_values ),
  acceleration AS (
  SELECT
    *,
    -- calculate acceleration
    (vx_1_change / (change_in_time / 1000)) AS ax_1,
    (vy_1_change / (change_in_time / 1000)) AS ay_1,
    (vz_1_change / (change_in_time / 1000)) AS az_1,
    (vx_2_change / (change_in_time / 1000)) AS ax_2,
    (vy_2_change / (change_in_time / 1000)) AS ay_2,
    (vz_2_change / (change_in_time / 1000)) AS az_2,
  FROM
    a_changes
  ORDER BY
    time)
SELECT
  time,
  ax_1,
  ay_1,
  az_1,
  ax_2,
  ay_2,
  az_2,
  trns_record_hash_code,
  run_uuid,
  CURRENT_TIMESTAMP() AS etl_update_ts
FROM
  acceleration