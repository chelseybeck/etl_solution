from __future__ import print_function

import os 
import datetime
import sys 

from airflow import DAG
from airflow.models.baseoperator import chain
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
    # clean_format.set_upstream(start_task)

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
    # convert_to_features.set_upstream(clean_format)

    # Match timestamps with measurements 
    match_values_timestamps = BigQueryOperator(
        task_id="match_values_timestamps",
        sql = 'sql/match_values_timestamps.sql',
        params = {"source_table": f'{project_id}.{etl_dataset}.w_features_converted'},
        destination_dataset_table = f'{project_id}.{etl_dataset}.w_timestamps_matched',
        create_disposition = "CREATE_IF_NEEDED",
        write_disposition = "WRITE_TRUNCATE",
        use_legacy_sql=False 
    )

    # match_values_timestamps.set_upstream(convert_to_features)

    # Interpolate null values between rows
    interpolate_values = BigQueryOperator(
        task_id="interpolate_values",
        sql = 'sql/interpolate_values.sql',
        params = {"source_table": f'{project_id}.{etl_dataset}.w_timestamps_matched'},
        destination_dataset_table = f'{project_id}.{target_dataset}.trns_base_values',
        create_disposition = "CREATE_IF_NEEDED",
        write_disposition = "WRITE_TRUNCATE",
        use_legacy_sql=False 
    )
    # interpolate_values.set_upstream(match_values_timestamps)

    # Calculate Velocity
    calculate_velocity = BigQueryOperator(
        task_id="calculate_velocity",
        sql = 'sql/calculate_velocity.sql',
        params = {"source_table": f'{project_id}.{target_dataset}.trns_base_values'},
        destination_dataset_table = f'{project_id}.{etl_dataset}.w_velocity_calculated',
        create_disposition = "CREATE_IF_NEEDED",
        write_disposition = "WRITE_TRUNCATE",
        use_legacy_sql=False 
    )
    # calculate_velocity.set_upstream(interpolate_values)

    # Calculate Acceleration
    calculate_acceleration = BigQueryOperator(
        task_id="calculate_acceleration",
        sql = 'sql/calculate_acceleration.sql',
        params = {"source_table": f'{project_id}.{etl_dataset}.w_velocity_calculated'},
        destination_dataset_table = f'{project_id}.{etl_dataset}.w_acceleration_calculated',
        create_disposition = "CREATE_IF_NEEDED",
        write_disposition = "WRITE_TRUNCATE",
        use_legacy_sql=False 
    )
    # calculate_velocity.set_upstream(calculate_velocity)

    # Calculate Force
    calculate_force = BigQueryOperator(
        task_id="calculate_force",
        sql = 'sql/calculate_force.sql',
        params = {"source_table": f'{project_id}.{target_dataset}.trns_base_values'},
        destination_dataset_table = f'{project_id}.{etl_dataset}.w_force_calculated',
        create_disposition = "CREATE_IF_NEEDED",
        write_disposition = "WRITE_TRUNCATE",
        use_legacy_sql=False 
    )
    # calculate_force.set_upstream(interpolate_values)

    # Combine Totals
    combine_totals = BigQueryOperator(
        task_id="combine_totals",
        sql = 'sql/combine_totals.sql',
        params = {
            "velocity_table": f'{project_id}.{etl_dataset}.w_velocity_calculated',
            "acceleration_table": f'{project_id}.{etl_dataset}.w_acceleration_calculated',
            "force_table": f'{project_id}.{etl_dataset}.w_force_calculated'
        },
        destination_dataset_table = f'{project_id}.{target_dataset}.trns_calculated_features',
        create_disposition = "CREATE_IF_NEEDED",
        write_disposition = "WRITE_TRUNCATE",
        use_legacy_sql=False 
    )
    # combine_totals.set_upstream([calculate_acceleration, calculate_force])

    # Summarize Totals
    summarize_totals = BigQueryOperator(
        task_id="summarize_totals",
        sql = 'sql/summarize_totals.sql',
        params = {"source_table": f'{project_id}.{target_dataset}.trns_calculated_features'},
        destination_dataset_table = f'{project_id}.{target_dataset}.trns_calculated_summary',
        create_disposition = "CREATE_IF_NEEDED",
        write_disposition = "WRITE_TRUNCATE",
        use_legacy_sql=False 
    )
    # summarize_totals.set_upstream(combine_totals)

    # Calculate Runtime Statistics
    calculate_runtime_stats = BigQueryOperator(
        task_id="calculate_runtime_stats",
        sql = 'sql/calculate_runtime_stats.sql',
        params = {
            "velocity_table": f'{project_id}.{etl_dataset}.w_velocity_calculated',
            "trns_base_table": f'{project_id}.{target_dataset}.trns_base_values',
        },
        destination_dataset_table = f'{project_id}.{target_dataset}.trns_runtime_stats',
        create_disposition = "CREATE_IF_NEEDED",
        write_disposition = "WRITE_TRUNCATE",
        use_legacy_sql=False 
    )
    # calculate_runtime_stats.set_upstream([calculate_velocity])
    divider = DummyOperator(task_id='divider')
    end_task = DummyOperator(task_id='end')
    # end_task.set_upstream([calculate_runtime_stats, summarize_totals])

    # Define the order in which the tasks complete
    chain(start_task, clean_format, convert_to_features, match_values_timestamps, interpolate_values, [calculate_velocity, calculate_force], divider, [calculate_acceleration, calculate_runtime_stats], combine_totals, summarize_totals, end_task) 
   
   
    # start_task >> clean_format >> convert_to_features >> match_values_timestamps >> interpolate_values
    # [calculate_velocity, calculate_force], [calculate_acceleration, calculate_runtime_stats], combine_totals, summarize_totals, end_task) 