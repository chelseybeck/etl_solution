# Overview | Sensor Data ETL Pipeline
This is an example pipeline built as a solution to an assignment provided by [Machina Labs](https://github.com/Machina-Labs/data_engineer_hw). It extracts robot sensor data, transforms it based on a set of specifications, and loads it into a data warehouse for downstream consumption.

# Tech Stack

- Google Cloud Platform (GCP)
- Apache Airflow - workflow as code - written in Python
  - Running on a GCP hosted Composer cluster
- BigQuery - Data warehouse
  - Transformation logic written in standard SQL

### Why these tools?  
- These are tools that I work with every day and am most familiar with. I have a GCP instance set up as a playground and was able to leverage those resources to automate this solution. 
- All are great choices for running ETL pipelines and were well-suited to this type of structured data.

# Project Structure 

# Continuous Integration / Development (CI/CD)
There are two separate environments, staging and main. Main is a protected branch and all code should be fully tested before merging dev to main. Changes  sends code to the cloud in a simulated production environment.  

## Environments
Code deployments are separated into two main environment branches, dev and main. Code deployed to the dev branch allows for testing before pushing changes to the cloud. Merging changes to main will push them to the cloud.

## GitHub Actions
- composer-ci.yaml - used to sync DAG directory (sensor_data_etl) with DAG bucket in GCP 
  - this action runs when a change is made to a file inside of the sensor_data_etl directory
  - it syncs with DAG bucket in GCP that houses Airflow DAGs

# ETL Data Flow Narrative
1. Extract parquet file from GCS bucket and import into a BigQuery table in the raw layer dataset (raw_sensor_data_prod)
2. Clean raw data
    - Deduplicate & trim
      - cast all columns to correct datatype based on the raw sensor data dictionary
      - Note: descriptive numbers are converted to strings in accordance with best practices
4. Convert Features
    - convert timeseries to features by robot_id
    - create hash codes (primary key) to tie back to raw layer
      - identifies each row w/ a unique key
      - helps in preventing appending duplicate data
5. Match timestamps with measurements
6. Calculated Features
   - 6 Velocity values (vx_1, vy_1, vz_1, vx_2, vy_2, vz_2)
   - 6 Acceleration values (ax_1, ay_1, az_1, ax_2, ay_2, az_2)
   - Total Velocity (v1, v2)
   - Total Acceleration (a1, a2)
   - Total Force (f1, f2)
7. Runtime Statistics
   - run_uuid
   - run start time
   - run stop time
   - total runtime
   - total distance draveled
8. Perform data quality (DQ) checks
9. Load final table into transformed layer of data warehouse for downstream consumption

# Access
# Contributing
## Adding tasks to the DAG
## Updating Transformation Logic

# Future Improvements / Enhancements