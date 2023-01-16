-- windows data by run_uuid and time and then fills column values
SELECT
  raw_record_hash_code,
  time,
  run_uuid,
  CASE
    WHEN fx_1 IS NOT NULL THEN fx_1
    WHEN fx_1 IS NULL
  THEN PERCENTILE_CONT(fx_1, 0) OVER (PARTITION BY run_uuid, time)
  ELSE
  NULL
END
  AS fx_1,
  CASE
    WHEN fy_1 IS NOT NULL THEN fy_1
    WHEN fy_1 IS NULL
  THEN PERCENTILE_CONT(fy_1, 0) OVER (PARTITION BY run_uuid, time)
  ELSE
  NULL
END
  AS fy_1,
  CASE
    WHEN fz_1 IS NOT NULL THEN fz_1
    WHEN fz_1 IS NULL
  THEN PERCENTILE_CONT(fz_1, 0) OVER (PARTITION BY run_uuid, time)
  ELSE
  NULL
END
  AS fz_1,
  CASE
    WHEN x_1 IS NOT NULL THEN x_1
    WHEN x_1 IS NULL
  THEN PERCENTILE_CONT(x_1, 0) OVER (PARTITION BY run_uuid, time)
  ELSE
  NULL
END
  AS x_1,
  CASE
    WHEN y_1 IS NOT NULL THEN y_1
    WHEN y_1 IS NULL
  THEN PERCENTILE_CONT(y_1, 0) OVER (PARTITION BY run_uuid, time)
  ELSE
  NULL
END
  AS y_1,
  CASE
    WHEN z_1 IS NOT NULL THEN z_1
    WHEN z_1 IS NULL
  THEN PERCENTILE_CONT(z_1, 0) OVER (PARTITION BY run_uuid, time)
  ELSE
  NULL
END
  AS z_1,
  CASE
    WHEN fx_2 IS NOT NULL THEN fx_2
    WHEN fx_2 IS NULL
  THEN PERCENTILE_CONT(fx_2, 0) OVER (PARTITION BY run_uuid, time)
  ELSE
  NULL
END
  AS fx_2,
  CASE
    WHEN fy_2 IS NOT NULL THEN fy_2
    WHEN fy_2 IS NULL
  THEN PERCENTILE_CONT(fy_2, 0) OVER (PARTITION BY run_uuid, time)
  ELSE
  NULL
END
  AS fy_2,
  CASE
    WHEN fz_2 IS NOT NULL THEN fz_2
    WHEN fz_2 IS NULL
  THEN PERCENTILE_CONT(fz_2, 0) OVER (PARTITION BY run_uuid, time)
  ELSE
  NULL
END
  AS fz_2,
  CASE
    WHEN x_2 IS NOT NULL THEN x_2
    WHEN x_2 IS NULL
  THEN PERCENTILE_CONT(x_2, 0) OVER (PARTITION BY run_uuid, time)
  ELSE
  NULL
END
  AS x_2,
  CASE
    WHEN y_2 IS NOT NULL THEN y_2
    WHEN y_2 IS NULL
  THEN PERCENTILE_CONT(y_2, 0) OVER (PARTITION BY run_uuid, time)
  ELSE
  NULL
END
  AS y_2,
  CASE
    WHEN z_2 IS NOT NULL THEN z_2
    WHEN z_2 IS NULL
  THEN PERCENTILE_CONT(z_2, 0) OVER (PARTITION BY run_uuid, time)
  ELSE
  NULL
END
  AS z_2,
FROM {{ params.source_table }}
ORDER BY time 