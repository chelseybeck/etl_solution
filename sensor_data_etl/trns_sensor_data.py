from __future__ import print_function

import os 
import datetime
import sys 

from airflow import DAG
from airflow.operators.dummy import DummyOperator
from airflow.contrib.operators.bigquery_operator import BigQueryOperator 

from google.cloud import bigquery 

from pathlib import Path

import_path = str(Path(os.path.abspath(os.path.dirname(__file__))).parent)
sys.path.insert(0, import_path)

default_dag_args = {
    # The start_date describes when a DAG is valid
    'start_date': datetime.datetime(2023, 1, 6),
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 0,
}

dag_name = 'trns_sensor_data_dag'
schedule_interval = None

raw_src_dataset = 'raw_sensor_data'
target_dataset = 'trns_sensor_data'
etl_dataset = 'w_sensor_data'
project_id = 'storied-storm-353916'

# Define a DAG (directed acyclic graph) of tasks.
with DAG(dag_name, catchup=False, default_args=default_dag_args, 
schedule_interval=schedule_interval) as dag:
    start_task = DummyOperator(task_id='start')

    # Run tasks:
    # 1. Ingest .parquet file from GCS to BigQuery
    # extract_parquet_file = BigQueryOperator(
    #     task_id = "gcs_to_bq_sensor_data",
    #     sql = "sql/extract_parquet_file.sql"
    # )

    # 2. Check current records
    # check to see ensure that this data has not already been transformed 
    # (does not match a record hash code in the transformed table.)

    # 3. Run transformation to clean data.
    # deduplicate, cast datatypes, and trim
    clean_data = BigQueryOperator(
        task_id="clean_data",
        sql = 'sql/clean_data.sql',
        params = {"raw_table_location":f'{project_id}.{raw_src_dataset}.sensor_data'},
        destination_dataset_table = f'{project_id}.{etl_dataset}.w_sensor_data_clean',
        create_disposition = "CREATE_IF_NEEDED",
        write_disposition = "WRITE_TRUNCATE",
        use_legacy_sql=False 
    )

    # 4. Convert timeseries to features by robot_id
    convert_to_features = BigQueryOperator(
        task_id="convert_to_features",
        sql = 'sql/convert_to_features.sql',
        params={"clean_table_location":f'{project_id}.{etl_dataset}.w_sensor_data_clean'},
        destination_dataset_table = f'{project_id}.{etl_dataset}.w_features_converted',
        create_disposition = "CREATE_IF_NEEDED",
        write_disposition = "WRITE_TRUNCATE",
        use_legacy_sql=False 
    )

    # 5. Match timestamps with measurements - TO DO
    match_timestamps = DummyOperator(task_id='match_timestamps')

    # 6. Add engineered/calculated features - TO DO
    add_calculated_features = DummyOperator(task_id='add_calculated_features')

    # 7. Calculate Runtime Statistics - TO DO
    calculate_runtime_stats = DummyOperator(task_id='calculate_runtime_stats')

    # 8. Load final table
    # load_final_table = BigQueryOperator(
    #     task_id="load_final_table",
    #     sql = 'sql/load_final_table.sql',
    #     destination_dataset_table = f'{project_id}.{target_dataset}.',
    #     create_disposition = "CREATE_IF_NEEDED",
    #     write_disposition = "WRITE_TRUNCATE",
    #     use_legacy_sql=False 
    # )

    # 9. Export table as csv to bucket
    # create GH action to download the file back to GH repo

    end_task = DummyOperator(task_id='end')

    # Define the order in which the tasks complete
    start_task >> clean_data >> convert_to_features >> match_timestamps >> [add_calculated_features, calculate_runtime_stats] >> end_task 