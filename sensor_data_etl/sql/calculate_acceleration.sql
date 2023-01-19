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
    {{ params.source_table }}
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
    CASE
      WHEN vx_1 != 0 THEN ABS(vx_1 - vx_1_prev_value)
    ELSE
    0
  END
    AS vx_1_change,
    CASE
      WHEN vy_1 != 0 THEN ABS(vy_1 - vy_1_prev_value)
    ELSE
    0
  END
    AS vy_1_change,
    CASE
      WHEN vz_1 != 0 THEN ABS(vz_1 - vz_1_prev_value)
    ELSE
    0
  END
    AS vz_1_change,
    CASE
      WHEN vx_2 != 0 THEN ABS(vx_2 - vx_2_prev_value)
    ELSE
    0
  END
    AS vx_2_change,
    CASE
      WHEN vy_2 != 0 THEN ABS(vy_2 - vy_2_prev_value)
    ELSE
    0
  END
    AS vy_2_change,
    CASE
      WHEN vz_2 != 0 THEN ABS(vz_2 - vz_2_prev_value)
    ELSE
    0
  END
    AS vz_2_change,
  FROM
    a_prev_values ),
  acceleration AS (
  SELECT
    *,
    CASE
      -- calculate acceleration
      WHEN vx_1 != 0 THEN (vx_1_change / (change_in_time / 1000))
    ELSE
    0
  END
    AS ax_1,
    CASE
      WHEN vy_1 != 0 THEN (vy_1_change / (change_in_time / 1000))
    ELSE
    0
  END
    AS ay_1,
    CASE
      WHEN vz_1 != 0 THEN (vz_1_change / (change_in_time / 1000))
    ELSE
    0
  END
    AS az_1,
    CASE
      WHEN vx_2 != 0 THEN (vx_2_change / (change_in_time / 1000))
    ELSE
    0
  END
    AS ax_2,
    CASE
      WHEN vy_2 != 0 THEN (vy_2_change / (change_in_time / 1000))
    ELSE
    0
  END
    AS ay_2,
    CASE
      WHEN vz_2 != 0 THEN (vz_2_change / (change_in_time / 1000))
    ELSE
    0
  END
    AS az_2,
  FROM
    a_changes
  ORDER BY
    time)
SELECT
  time,
  ax_1,
  -- get totals 
  SUM(ax_1) OVER win1 AS total_ax_1,
  ay_1,
  SUM(ay_1) OVER win1 AS total_ay_1,
  az_1,
  SUM(az_1) OVER win1 AS total_az_1,
  ax_2,
  SUM(ax_2) OVER win1 AS total_ax_2,
  ay_2,
  SUM(ay_2) OVER win1 AS total_ay_2,
  az_2,
  SUM(az_2) OVER win1 AS total_az_2,
  run_uuid,
  trns_record_hash_code,
  CURRENT_TIMESTAMP AS etl_update_ts
FROM
  acceleration
WINDOW
  win1 AS (
  PARTITION BY
    run_uuid
  ORDER BY
    time ROWS BETWEEN UNBOUNDED PRECEDING
    AND CURRENT ROW )
ORDER BY
  time