-- summarize calculations for summary table
SELECT
  run_uuid,
  CASE
    WHEN vx_1 IS NULL THEN 0
  ELSE 
  MAX(vx_1) 
END 
  AS vx_1,
  CASE 
    WHEN vy_1 IS NULL THEN 0
  ELSE 
  MAX(vy_1) 
END 
  AS vy_1,
  CASE 
    WHEN vz_1 IS NULL THEN 0
  ELSE 
  MAX(vz_1)
END 
  AS vz_1,
  CASE 
    WHEN vx_2 IS NULL THEN 0
  ELSE  
  MAX(vx_2) 
END 
  AS vx_2,
  CASE 
    WHEN vy_2 IS NULL THEN 0
  ELSE 
  MAX(vy_2) 
END AS vy_2,
  CASE 
    WHEN vz_2 IS NULL THEN 0 
  ELSE 
  MAX(vz_2) 
END 
  AS vz_2,
  CASE 
    WHEN ax_1 IS NULL THEN 0
  ELSE 
  MAX(ax_1) 
END 
  AS ax_1,
  CASE 
    WHEN ay_1 IS NULL THEN 0 
  ELSE 
  MAX(ay_1) 
END 
  AS ay_1,
  CASE 
    WHEN az_1 IS NULL THEN 0 
  ELSE 
  MAX(az_1) 
END 
  AS az_1,
  CASE 
    WHEN ax_2 IS NULL THEN 0
  ELSE 
  MAX(ax_2) 
END 
  AS ax_2,
  CASE 
    WHEN ay_2 IS NULL THEN 0
  ELSE 
  MAX(ay_2) 
END 
  AS ay_2,
  CASE 
    WHEN az_2 IS NULL THEN 0 
  ELSE 
  MAX(az_2) 
END 
  AS az_2,
  CASE 
    WHEN v1 IS NULL THEN 0
  ELSE 
  MAX(v1) 
END 
  AS v1,
  CASE 
    WHEN v2 IS NULL THEN 0
  ELSE 
  MAX(v2) 
END 
  AS v2,
  CASE 
    WHEN a1 IS NULL THEN 0
  ELSE 
  MAX(a1) 
END 
  AS a1,
  CASE 
    WHEN a2 IS NULL THEN 0
  ELSE 
  MAX(a2) 
END 
  AS a2,
  CASE 
    WHEN f1 IS NULL THEN 0
  ELSE 
  MAX(f1) 
END 
  AS f1,
CASE 
  WHEN f2 IS NULL THEN 0
  ELSE 
  MAX(f2) 
END 
  AS f2
FROM
  {{ params.source_table }}
GROUP BY
  run_uuid