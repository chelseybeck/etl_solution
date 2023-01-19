SELECT
  time,
  fx_1,
  -- create running total using absolute values of force
  SUM(ABS(fx_1)) OVER win1 AS total_fx_1,
  fy_1,
  SUM(ABS(fy_1)) OVER win1 AS total_fy_1,
  fz_1,
  SUM(ABS(fz_1)) OVER win1 AS total_fz_1,
  fx_2,
  SUM(ABS(fx_2)) OVER win1 AS total_fx_2,
  fy_2,
  SUM(ABS(fy_2)) OVER win1 AS total_fy_2,
  fz_2,
  SUM(ABS(fz_2)) OVER win1 AS total_fz_2,
  run_uuid,
  trns_record_hash_code,
  CURRENT_TIMESTAMP AS etl_update_ts
FROM
  {{ params.source_table }}
WINDOW
  win1 AS (
  PARTITION BY
    run_uuid
  ORDER BY
    time ROWS BETWEEN UNBOUNDED PRECEDING
    AND CURRENT ROW )
ORDER BY
  time