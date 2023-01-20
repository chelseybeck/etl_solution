WITH
  main AS (
  SELECT
    t.*,
    v.x_1_displacement,
    v.y_1_displacement,
    v.z_1_displacement,
    v.x_2_displacement,
    v.y_2_displacement,
    v.z_2_displacement,
  FROM
    {{ params.trns_base_table }} t
  INNER JOIN
    {{ params.velocity_table }} v
  ON
    t.trns_record_hash_code = v.trns_record_hash_code),
  distance AS (
  SELECT
    *,
    -- CASE WHEN logic is required here to make the null values zero
    -- otherwise MAX in final selection statement will not calculate correctly
    CASE
      WHEN x_1_displacement IS NULL THEN 0
    ELSE
    SUM(x_1_displacement) OVER win1
  END
    AS x_1_sum,
    CASE
      WHEN y_1_displacement IS NULL THEN 0
    ELSE
    SUM(y_1_displacement) OVER win1
  END
    AS y_1_sum,
    CASE
      WHEN z_1_displacement IS NULL THEN 0
    ELSE
    SUM(z_1_displacement) OVER win1
  END
    AS z_1_sum,
    CASE
      WHEN x_2_displacement IS NULL THEN 0
    ELSE
    SUM(x_2_displacement) OVER win1
  END
    AS x_2_sum,
    CASE
      WHEN y_2_displacement IS NULL THEN 0
    ELSE
    SUM(y_2_displacement) OVER win1
  END
    AS y_2_sum,
    CASE
      WHEN z_2_displacement IS NULL THEN 0
    ELSE
    SUM(z_2_displacement) OVER win1
  END
    AS z_2_sum
  FROM
    main
  WINDOW
    win1 AS (
    PARTITION BY
      run_uuid
    ORDER BY
      time ROWS BETWEEN UNBOUNDED PRECEDING
      AND CURRENT ROW )
  ORDER BY
    time)
SELECT
  run_uuid,
  MIN(time) AS run_start_time,
  MAX(time) AS run_stop_time,
  -- runtime in seconds
  ROUND((ABS(TIMESTAMP_DIFF(MAX(time), MIN(time), MILLISECOND)) / 1000), 5) AS run_time,
  -- distance in meters
  MAX(x_1_sum) + MAX(y_1_sum) + MAX(z_1_sum) + MAX(x_2_sum) + MAX(y_2_sum) AS total_distance_travelled,
  CURRENT_TIMESTAMP() AS etl_update_ts
FROM
  distance
GROUP BY
  run_uuid