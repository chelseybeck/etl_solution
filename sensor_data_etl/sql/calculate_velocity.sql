 WITH
  prev_value AS (
  SELECT
    trns_record_hash_code,
    time,
    run_uuid,
    -- find the time from the previous row in the window
    -- used for calculating change in time between readings
    LAG(time) OVER win1 AS prev_time,
    x_1,
    -- find the value from the previous row in the window
    -- used for calculating displacement
    LAG(x_1) OVER win1 AS x_1_prev_value,
    y_1,
    LAG(y_1) OVER win1 AS y_1_prev_value,
    z_1,
    LAG(z_1) OVER win1 AS z_1_prev_value,
    x_2,
    LAG(x_2) OVER win1 AS x_2_prev_value,
    y_2,
    LAG(y_2) OVER win1 AS y_2_prev_value,
    z_2,
    LAG(z_2) OVER win1 AS z_2_prev_value
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
  changes AS(
  SELECT
    *,
    -- calculate displacement
    ABS(TIMESTAMP_DIFF(time, prev_time, MILLISECOND)) AS change_in_time,
    ABS(x_1 - x_1_prev_value) AS x_1_displacement,
    ABS(y_1 - y_1_prev_value) AS y_1_displacement,
    ABS(z_1 - z_1_prev_value) AS z_1_displacement,
    ABS(x_2 - x_2_prev_value) AS x_2_displacement,
    ABS(y_2 - y_2_prev_value) AS y_2_displacement,
    ABS(z_2 - z_2_prev_value) AS z_2_displacement
  FROM
    prev_value 
  ),
  velocity AS (SELECT
    time,
    x_1_displacement,
    y_1_displacement,
    z_1_displacement,
    x_2_displacement,
    y_2_displacement,
    z_2_displacement,
    -- calculate velocity displacement / change in time
    -- displacement to time is millimeters to milliseconds
    -- divide each by 1000 to convert to meters per seconds
    ((x_1_displacement / 1000) / (change_in_time / 1000)) AS vx_1,
    ((y_1_displacement / 1000) / (change_in_time / 1000)) AS vy_1,
    ((z_1_displacement / 1000) / (change_in_time / 1000)) AS vz_1,
    ((x_2_displacement / 1000) / (change_in_time / 1000)) AS vx_2,
    ((y_2_displacement / 1000) / (change_in_time / 1000)) AS vy_2,
    ((z_2_displacement / 1000) / (change_in_time / 1000)) AS vz_2,
    run_uuid,
    trns_record_hash_code
  FROM
    changes
  ORDER BY
    time)
-- calculate totals
SELECT 
time,
    vx_1,
    SUM(vx_1) OVER win1 AS total_vx_1,
    vy_1,
    SUM(vy_1) OVER win1 AS total_vy_1,
    vz_1,
    SUM(vz_1) OVER win1 AS total_vz_1,
    vx_2,
    SUM(vx_2) OVER win1 AS total_vx_2,
    vy_2,
    SUM(vy_2) OVER win1 AS total_vy_2,
    vz_2,
    SUM(vz_2) OVER win1 AS total_vz_2,
    -- displacement columns were added in the SELECT here because
    -- we need to pull from these columns to calculate runtime stats
    -- in another task
    x_1_displacement,
    y_1_displacement,
    z_1_displacement,
    x_2_displacement,
    y_2_displacement,
    z_2_displacement,
    run_uuid,
    trns_record_hash_code,
    CURRENT_TIMESTAMP AS etl_update_ts
FROM velocity
WINDOW
    win1 AS (
    PARTITION BY
      run_uuid
    ORDER BY
      time ROWS BETWEEN UNBOUNDED PRECEDING
      AND CURRENT ROW )
  ORDER BY
  time 