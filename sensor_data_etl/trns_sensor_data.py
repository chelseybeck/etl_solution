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

    # Run transformation to clean data.
    # deduplicate, cast datatypes, and trim
    clean_format = BigQueryOperator(
        task_id="clean_format",
        sql = 'sql/clean_format.sql',
        params = {"source_table":f'{project_id}.{raw_src_dataset}.sensor_data'},
        destination_dataset_table = f'{project_id}.{etl_dataset}.w_sensor_data_clean',
        create_disposition = "CREATE_IF_NEEDED",
        write_disposition = "WRITE_TRUNCATE",
        use_legacy_sql=False 
    )
    clean_format.set_upstream(start_task)

    # Convert timeseries to features by robot_id
    convert_to_features = BigQueryOperator(
        task_id="convert_to_features",
        sql = 'sql/convert_to_features.sql',
        params={"source_table":f'{project_id}.{etl_dataset}.w_sensor_data_clean'},
        destination_dataset_table = f'{project_id}.{etl_dataset}.w_features_converted',
        create_disposition = "CREATE_IF_NEEDED",
        write_disposition = "WRITE_TRUNCATE",
        use_legacy_sql=False 
    )
    convert_to_features.set_upstream(clean_format)

    # Using dummy operators for tasks not yet written
    # Match timestamps with measurements - DONE
    match_values_timestamps = BigQueryOperator(
        task_id="match_values_timestamps",
        sql = 'sql/match_values_timestamps.sql',
        params = {"source_table": f'{project_id}.{etl_dataset}.w_features_converted'},
        destination_dataset_table = f'{project_id}.{etl_dataset}.w_timestamps_matched',
        create_disposition = "CREATE_IF_NEEDED",
        write_disposition = "WRITE_TRUNCATE",
        use_legacy_sql=False 
    )

    match_values_timestamps.set_upstream(convert_to_features)

    # Interpolate null values between rows
    interpolate_values = BigQueryOperator(
        task_id="interpolate_values",
        sql = 'sql/interpolate_values.sql',
        params = {"source_table": f'{project_id}.{etl_dataset}.w_timestamps_matched'},
        destination_dataset_table = f'{project_id}.{etl_dataset}.w_values_interpolated',
        create_disposition = "CREATE_IF_NEEDED",
        write_disposition = "WRITE_TRUNCATE",
        use_legacy_sql=False 
    )

    interpolate_values.set_upstream(match_values_timestamps)

    # Add engineered/calculated features - IN PROGRESS
    add_calculated_features = DummyOperator(task_id='add_calculated_features')
    add_calculated_features.set_upstream(interpolate_values)

    # Calculate Runtime Statistics - IN PROGRESS
    calculate_runtime_stats = DummyOperator(task_id='calculate_runtime_stats')
    calculate_runtime_stats.set_upstream(interpolate_values)

    # Load final table
    load_trns_table = BigQueryOperator(
        task_id="load_trns_table",
        sql = 'sql/load_final_table.sql',
        # Change source table below once rest of features are added
        params = {"source_table": f'{project_id}.{etl_dataset}.w_values_interpolated'},
        destination_dataset_table = f'{project_id}.{target_dataset}.trns_sensor_data',
        create_disposition = "CREATE_IF_NEEDED",
        write_disposition = "WRITE_TRUNCATE",
        use_legacy_sql=False 
    )

    load_trns_table.set_upstream(add_calculated_features)

    # Export table as csv to bucket
    # create GH action to download the file back to GH repo

    end_task = DummyOperator(task_id='end')
    end_task.set_upstream([calculate_runtime_stats, load_trns_table])

    # Define the order in which the tasks complete
    # For now, I'm making them more explicit above, but can convert back to this format
    # start_task >> clean_data >> convert_to_features >> match_timestamps >> [add_calculated_features, calculate_runtime_stats] >> end_task 