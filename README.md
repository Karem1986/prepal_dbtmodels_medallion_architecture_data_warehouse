# Prepal Migration to dbt and orquestration through Airflow

Prepal (fictitous name) is a retailer company that makes sustainable food packages.
This project highlights how I solved two of their problems. Te first one was the lack of automation in the sql queries, which had to be done manually by the data analyst.

The client's data is in a SAP environment and on-premises.

This project demonstrates a production-grade, cost-effective Data Warehouse architecture designed to unify hybrid enterprise data streams specifically an API-driven Cloud ERP (SAP) and an On-Premises Warehouse Management System (WMS) into a Kimball Star Schema optimized for Power BI reporting.

The architecture leverages Apache Airflow for isolated ingestion and automated data pipelines orquestration, a SQL database engine for compute and dbt to manage the Medallion transformation layers, eliminating the need for expensive cloud warehouse licenses while maintaining enterprise data governance.

The goal: decrease the time it takes to make power bi reports and use dbt to automate the ELT pipelines.4
In order to achieve this goal, I perform a migration from  SQL store procedures to dbt models, this will also enhance team collaboration, and monitoring.

## Security best practices

I do not hardcode credentials into configuration files. I separated configuration from code by utilizing an external .env file that is strictly blacklisted in .gitignore.

In our docker-compose.yml, the environment keys are dynamically injected at startup via host substitution. This exactly mirrors how a senior engineer prepares infrastructure for a production CI/CD pipeline where these exact same variables would be injected by a secure environment controller, such as GitHub Actions secrets or Azure Key Vault, without modifying a single line of application configuration

## Simulation SQL Store Procedures

In order to do the demo of how store procedures work and how this approach is improved with dbt, I made a simulation implementing two store procedures, one for extracting the data from SAP and the other store procedure for loading the data that contains only price information on the DW On-Premises of the client.

## Orchestration Layer (Airflow DAG)

Airflow acts as the automated heartbeat. It triggers a lightweight Python operator that makes the SAP API HTTP request and executes the on-premises database synchronization, dumping raw data into the Bronze staging area without putting prolonged operational strain on production systems.

## DBT vs SQL

The transformation of the data (Silver layer) occurs within dbt models, which is far way better than using SQL stored procedures in the DW. With dbt models it is possible to automate these transformations, incentivate collaboration, allow monitoring and testing. Data lineage, being able to see the entire process from extraction to final transformations, is also possible with dbt.
