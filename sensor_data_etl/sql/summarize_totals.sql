-- summarize calculations for summary table
SELECT  
run_uuid,
SUM(vx_1) AS total_vx_1,
SUM(vy_1) AS total_vy_1,
SUM(vz_1) AS total_vz_1,
SUM(vx_2) AS total_vx_2,
SUM(vy_2) AS total_vy_2,
SUM(vz_2) AS total_vz_2,
SUM(v1) AS total_v1,
SUM(v2) AS total_v2,
SUM(f1) AS total_f1,
SUM(f2) AS total_f2
FROM {{ params.source_table }} 
GROUP BY run_uuid 