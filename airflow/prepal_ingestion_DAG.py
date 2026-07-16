# Here we have our DAG workflow to run the extraction and load of data from Prepal.
# In a later phase, I will spin up Airflow on port 8085. 
# This DAG file (prepal_ingestion_dag.py) is designed to connect via the Docker network 
# using the host alias prepal_postgres rather than localhost, ensuring that once the Airflow container is live,
# it can immediately orchestrate our parallel ingestion tasks
from datetime import datetime, timedelta
from airflow import DAG
from airflow.providers.postgres.operators.postgres import PostgresOperator # type: ignore
from airflow.operators.empty import EmptyOperator # type: ignore

# 1. Error handling: if a task fails it will retry every 5 mins
default_args = {
    'owner': 'karem',
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

# 2. Define the DAG schedule
with DAG(
    dag_id='prepal_medallion_ingestion',
    default_args=default_args,
    description='Orchestrates PrePal legacy stored procedures',
    schedule_interval='0 2 * * *',  # Run daily at 2:00 AM
    start_date=datetime(2026, 7, 17),
    catchup=False,
) as dag:

    # 3.Tasks (What are we running?)
    start = EmptyOperator(
        task_id='start_pipeline'
    )

    extract_sap = PostgresOperator(
        task_id='extract_sap_orders',
        postgres_conn_id='prepal_postgres_conn',  # Set up in Airflow UI
        sql="CALL bronze_sap.usp_extract_sap_orders();"
    )

    sync_retail = PostgresOperator(
        task_id='sync_retail_transactions',
        postgres_conn_id='prepal_postgres_conn',
        sql="CALL bronze_onprem.usp_sync_retail_transactions();"
    )

    # 4. Parallel Execution
    start >> [extract_sap, sync_retail]