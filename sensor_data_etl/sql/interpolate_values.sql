WITH main AS (
  SELECT
    DISTINCT * EXCEPT(raw_record_hash_code)
  FROM
    {{ params.source_table }}),
  -- interpolates across null values using midpoint of surrounding non-null values
  interpolate AS (
  SELECT
    time,
    run_uuid,
    IFNULL(fx_1, (fx_1_start_value + fx_1_end_value) / 2) AS fx_1,
    IFNULL(fy_1, (fy_1_start_value + fy_1_end_value) / 2) AS fy_1,
    IFNULL(fz_1, (fz_1_start_value + fz_1_end_value) / 2) AS fz_1,
    IFNULL(x_1, ROUND((x_1_start_value + x_1_end_value) / 2, 3)) AS x_1,
    IFNULL(y_1, ROUND((y_1_start_value + y_1_end_value) / 2, 3)) AS y_1,
    IFNULL(z_1, ROUND((z_1_start_value + z_1_end_value) / 2, 3)) AS z_1,
    IFNULL(fx_2, (fx_2_start_value + fx_2_end_value) / 2) AS fx_2,
    IFNULL(fy_2, (fy_2_start_value + fy_2_end_value) / 2) AS fy_2,
    IFNULL(fz_2, (fz_2_start_value + fz_2_end_value) / 2) AS fz_2,
    IFNULL(x_2, ROUND((x_2_start_value + x_2_end_value) / 2, 3)) AS x_2,
    IFNULL(y_2, ROUND((y_2_start_value + y_2_end_value) / 2, 3)) AS y_2,
    IFNULL(z_2, ROUND((z_2_start_value + z_2_end_value) / 2, 3)) AS z_2,
  FROM (
    SELECT
      time,
      run_uuid,
      fx_1,
      FIRST_VALUE(fx_1 IGNORE NULLS) OVER win1 AS fx_1_start_value,
      FIRST_VALUE(fx_1 IGNORE NULLS) OVER win2 AS fx_1_end_value,
      fy_1,
      FIRST_VALUE(fy_1 IGNORE NULLS) OVER win1 AS fy_1_start_value,
      FIRST_VALUE(fy_1 IGNORE NULLS) OVER win2 AS fy_1_end_value,
      fz_1,
      FIRST_VALUE(fz_1 IGNORE NULLS) OVER win1 AS fz_1_start_value,
      FIRST_VALUE(fz_1 IGNORE NULLS) OVER win2 AS fz_1_end_value,
      x_1,
      FIRST_VALUE(x_1 IGNORE NULLS) OVER win1 AS x_1_start_value,
      FIRST_VALUE(x_1 IGNORE NULLS) OVER win2 AS x_1_end_value,
      y_1,
      FIRST_VALUE(y_1 IGNORE NULLS) OVER win1 AS y_1_start_value,
      FIRST_VALUE(y_1 IGNORE NULLS) OVER win2 AS y_1_end_value,
      z_1,
      FIRST_VALUE(z_1 IGNORE NULLS) OVER win1 AS z_1_start_value,
      FIRST_VALUE(z_1 IGNORE NULLS) OVER win2 AS z_1_end_value,
      fx_2,
      FIRST_VALUE(fx_2 IGNORE NULLS) OVER win1 AS fx_2_start_value,
      FIRST_VALUE(fx_2 IGNORE NULLS) OVER win2 AS fx_2_end_value,
      fy_2,
      FIRST_VALUE(fy_2 IGNORE NULLS) OVER win1 AS fy_2_start_value,
      FIRST_VALUE(fy_2 IGNORE NULLS) OVER win2 AS fy_2_end_value,
      fz_2,
      FIRST_VALUE(fz_2 IGNORE NULLS) OVER win1 AS fz_2_start_value,
      FIRST_VALUE(fz_2 IGNORE NULLS) OVER win2 AS fz_2_end_value,
      x_2,
      FIRST_VALUE(x_2 IGNORE NULLS) OVER win1 AS x_2_start_value,
      FIRST_VALUE(x_2 IGNORE NULLS) OVER win2 AS x_2_end_value,
      y_2,
      FIRST_VALUE(y_2 IGNORE NULLS) OVER win1 AS y_2_start_value,
      FIRST_VALUE(y_2 IGNORE NULLS) OVER win2 AS y_2_end_value,
      z_2,
      FIRST_VALUE(z_2 IGNORE NULLS) OVER win1 AS z_2_start_value,
      FIRST_VALUE(z_2 IGNORE NULLS) OVER win2 AS z_2_end_value,
    FROM
      main
    WINDOW
      win1 AS (
      PARTITION BY
        run_uuid
      ORDER BY
        time DESC ROWS BETWEEN CURRENT ROW
        AND UNBOUNDED FOLLOWING),
      win2 AS (
      PARTITION BY
        run_uuid
      ORDER BY
        time ROWS BETWEEN CURRENT ROW
        AND UNBOUNDED FOLLOWING)
    ORDER BY
      time ) )
-- above interpolation will not fill rows where first value is null
-- fill remaining null values with first populated value
SELECT
  time,
  IFNULL(fx_1, LAST_VALUE(fx_1 IGNORE NULLS) OVER win3) AS fx_1,
  IFNULL(fy_1, LAST_VALUE(fy_1 IGNORE NULLS) OVER win3) AS fy_1,
  IFNULL(fz_1, LAST_VALUE(fz_1 IGNORE NULLS) OVER win3) AS fz_1,
  IFNULL(x_1, LAST_VALUE(x_1 IGNORE NULLS) OVER win3) AS x_1,
  IFNULL(y_1, LAST_VALUE(y_1 IGNORE NULLS) OVER win3) AS y_1,
  IFNULL(z_1, LAST_VALUE(z_1 IGNORE NULLS) OVER win3) AS z_1,
  IFNULL(fx_2, LAST_VALUE(fx_2 IGNORE NULLS) OVER win3) AS fx_2,
  IFNULL(fy_2, LAST_VALUE(fy_2 IGNORE NULLS) OVER win3) AS fy_2,
  IFNULL(fz_2, LAST_VALUE(fz_2 IGNORE NULLS) OVER win3) AS fz_2,
  IFNULL(x_2, LAST_VALUE(x_2 IGNORE NULLS) OVER win3) AS x_2,
  IFNULL(y_2, LAST_VALUE(y_2 IGNORE NULLS) OVER win3) AS y_2,
  IFNULL(z_2, LAST_VALUE(z_2 IGNORE NULLS) OVER win3) AS z_2,
  run_uuid 
FROM
  interpolate
WINDOW 
  win3 AS (
  PARTITION BY
    run_uuid 
  ORDER BY
    time DESC )
ORDER BY
  time