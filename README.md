# ELT Pipeline with MySQL, Trino, dbt, Soda & Apache Superset


![MySQL](https://img.shields.io/badge/MySQL-8.4-4479A1?logo=mysql&logoColor=white)
![Trino](https://img.shields.io/badge/Trino-484-5890FF?logo=trino&logoColor=white)
![dbt](https://img.shields.io/badge/dbt-1.10+-FF694B?logo=dbt&logoColor=white)
![Soda](https://img.shields.io/badge/Soda-Data_Contracts-6C47FF)
![Apache Superset](https://img.shields.io/badge/Apache%20Superset-4.1.1-20A7C9?logo=apache-superset&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-Compose-2496ED?logo=docker&logoColor=white)
![Python](https://img.shields.io/badge/Python-3.12+-3776AB?logo=python&logoColor=white)
![uv](https://img.shields.io/badge/uv-Package_Manager-DE5FE9?logo=uv&logoColor=white)


An end-to-end ELT pipeline that transforms e-commerce sales data using **MySQL, Trino, dbt, and Soda**, with Apache Superset providing the data visualization layer.

The project demonstrates how to build an analytics platform where raw transactional data is transformed into analytics-ready models, validated through data quality checks and contracts, and made available for business intelligence.




## Architecture


## Prerequisites

Ensure you have the following installed:

- Docker
- Docker Compose
- Python 3.12+
- uv package manager

## 1. Clone the Repository

```bash
https://github.com/zablon-oigo/dbt-mysql-trino-elt-pipeline.git
cd dbt-mysql-trino-elt-pipeline
```

## 2. Start the Infrastructure

Start the project services using Docker Compose:

```bash
docker compose up -d --build
```

Check that the containers are running:

```bash
docker compose ps
```

The infrastructure includes:

- MySQL: Source database.
- Trino: SQL query engine.
- Apache Superset: Business intelligence and visualization platform.

## 3. Configure MySQL

Connect to the MySQL container:

```bash
docker exec -it elt-mysql mysql -u root -p
```

Create the analytics database and grant the Trino user the required permissions:

```sql
CREATE DATABASE analytics_db;

GRANT ALL PRIVILEGES ON analytics_db.*
TO 'elt_user'@'%';

FLUSH PRIVILEGES;
```

The `analytics_db` database will be used to store the transformed analytics models.

## 4. Run dbt Transformations

Navigate to the dbt project directory:

```bash
cd analytics
```

Install the project dependencies:

```bash
uv sync
```

Run all transformations and tests:

```bash
uv run dbt build
```

Alternatively, execute the transformation layers individually.

**Staging**

Staging models clean and standardize the raw source data.

```bash
uv run dbt run --select staging
```

**Intermediate**

Intermediate models combine and prepare data for business-level transformations.

```bash
uv run dbt run --select intermediate
```

**Marts**

Mart models produce analytics-ready fact and dimension tables.

```bash
uv run dbt run --select marts
```

Generate and serve dbt documentation:

```bash
uv run dbt docs generate
uv run dbt docs serve
```

The documentation provides a browsable view of the models, dependencies, and transformation lineage.


## 5. Verify Trino Connectivity

Before running dbt, confirm that Trino is accessible.



You can also access the Trino CLI:

```bash
docker exec -it elt-trino trino
```

List the available catalogs:

```sql
SHOW CATALOGS;
```

Inspect the source catalog:

```sql
SHOW SCHEMAS FROM source;
```

Check the source database:

```sql
USE source.analytics_db;

SHOW TABLES;
```

## 6. Configure Soda

Soda is responsible for validating data quality and enforcing data contracts.

While dbt tests validate transformation logic during the build process, Soda contracts provide an additional layer of protection for downstream consumers.

In this project, Soda validates the analytics models before they are consumed by Superset.

### Test the Data Source

From the directory containing `config.yml`, run:

```bash
soda data-source test -ds config.yml
```

This verifies that Soda can connect to the configured data source.

### Define Data Contracts

The `soda/` directory contains contracts for the fact and dimension tables.

| Contract | Description |
|---|---|
| `fct_orders.yml` | Validates order-related data |
| `fct_payments.yml` | Validates payment data |
| `dim_customers.yml` | Validates customer data |
| `dim_offices.yml` | Validates office data |
| `dim_employees.yml` | Validates employee data |
| `dim_products.yml` | Validates product data |

Each contract defines expectations that the corresponding dataset must satisfy.

### Test Data Contracts

Run the contract tests:

```bash
soda contract test --contract soda/fct_orders.yml
soda contract test --contract soda/fct_payments.yml

soda contract test --contract soda/dim_customers.yml
soda contract test --contract soda/dim_offices.yml
soda contract test --contract soda/dim_employees.yml
soda contract test --contract soda/dim_products.yml
```

### Verify Data Contracts

Verify the contracts against the configured data source:

```bash
soda contract verify \
  --data-source config.yml \
  --contract soda/fct_orders.yml

soda contract verify \
  --data-source config.yml \
  --contract soda/fct_payments.yml

soda contract verify \
  --data-source config.yml \
  --contract soda/dim_customers.yml
  
soda contract verify \
  --data-source config.yml \
  --contract soda/dim_offices.yml
```

Repeat the verification for the remaining fact and dimension contracts.

**Why Data Contracts?**

Data quality issues can propagate to dashboards and affect business decisions.

dbt tests help catch problems during transformations, while Soda contracts provide an additional validation layer for downstream consumers.

Together, they help ensure that the datasets exposed to Superset meet their expected quality requirements.

## 7. Connect Apache Superset to Trino

Once the dbt transformations have completed and the analytics tables are available through Trino, configure Superset to consume them.

Generate a Superset secret key:

```bash
openssl rand -base64 42
```

Add the generated key to your Superset configuration or environment variables as `SUPERSET_SECRET_KEY`.

From the Superset container:

```bash
docker exec -it superset \
  curl -v http://trino:8080/v1/info
```

In Superset:

1. Navigate to **Settings → Database Connections**.
2. Select **Add Database**.
3. Choose Trino as the database engine.
4. Configure the connection using:

```text
trino://admin@trino:8080/source
```

5. Test the connection and save it.

You can now browse the analytics tables exposed through Trino, create datasets, and build dashboards.

#### Dashboard
<img width="1900" height="938" alt="image" src="https://github.com/user-attachments/assets/61d89d5e-0b9a-417d-9dbd-9e35fab007aa" />


