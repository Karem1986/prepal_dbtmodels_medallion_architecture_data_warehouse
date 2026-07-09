# prepal_dbtmodels_medallion_architecture_data_warehouse

Prepal (fictitous name) is a retailer company, this project highlights how I solved the client's problems. The client already had a data warehouse of type 'on-premises' which had data from different sources: SAP and other on-premises sources. 
This project demonstrates a production-grade, cost-effective Data Warehouse architecture designed to unify hybrid enterprise data streams—specifically an API-driven Cloud ERP (SAP) and an On-Premises Warehouse Management System (WMS) into a Kimball Star Schema optimized for Power BI reporting.
The architecture leverages Apache Airflow for isolated ingestion, a SQL database engine for compute, and dbt to manage the Medallion transformation layers, eliminating the need for expensive cloud warehouse licenses while maintaining enterprise data governance.

The goal: decrease the time it takes to make the power bi reports and use dbt to automate the ELT pipelines once I migrate from store procedures to dbt models, also to enhance collaboration, tracking and monitoring with other members of the Sofware Engineering team.

## Orchestration Layer (Airflow DAG)

Airflow acts as the automated heartbeat. It triggers a lightweight Python operator that makes the SAP API HTTP request and executes the on-premises database synchronization, dumping raw data into the Bronze staging area without putting prolonged operational strain on production systems.

## DBT vs SQL

The transformation of the data (Silver layer) occurs within dbt models, which is far way better than using SQL stored procedures in the DW. With dbt models it is possible to automate these transformations, incentivate collaboration, allow monitoring and testing. Data lineage, being able to see the entire process from extraction to final transformations, is also possible with dbt.
