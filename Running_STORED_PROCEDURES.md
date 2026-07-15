# Instructions to run the local Postgres Database using Docker compose 

1. To spin it up after cloning this repo:

        'docker-compose up -d'

2. To shut it down:
        'docker-compose down'

3. To run the data script via CLI, in the directory where the schema, tables and procedures are created:
        'cat init_db.sql | docker exec -i prepal_postgres psql -U admin -d prepal_dwh'
Or via a VSC plugin. The Output should look like:
                CREATE SCHEMA
                CREATE SCHEMA
                CREATE SCHEMA
                CREATE TABLE
                CREATE TABLE
                CREATE TABLE
                CREATE PROCEDURE
                CREATE PROCEDURE
4. Test if the stored procedures were saved successfully
                'cat test_run.sql | docker exec -i prepal_postgres psql -U admin -d prepal_dwh'
If status shows: SUCCESS, 2 rows and you see your stored procedures,schema and tables were successfully created.
