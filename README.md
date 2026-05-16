# DS206 Project 2 - Group 4

## Project Overview

This project builds a Dimensional Data Store (DDS) for an order/sales dataset and prepares the data for Business Intelligence analysis.

The project uses a Northwind-style dataset stored in `raw_data_source.xlsx`. The pipeline loads raw Excel data into staging tables, creates and updates dimension tables, updates the fact table for a selected date range, and stores faulty fact rows in a fact error table.

The final output of the project is a structured dimensional database that can be connected to a Power BI dashboard for sales and operational analysis.

---

## Repository Structure

```text
DS206_Project2_Group4/
├── dashboard/
│   └── group4_dashboard.pbix
│
├── infrastructure_initiation/
│   ├── dimensional_database_creation.sql
│   ├── dimensional_db_table_creation.sql
│   ├── staging_raw_table_creation.sql
│   └── sql_server_config.cfg
│
├── logs/
│   └── logs_dimensional_data_pipeline.txt
│
├── pipeline_dimensional_data/
│   ├── __init__.py
│   ├── flow.py
│   ├── tasks.py
│   └── queries/
│       ├── update_dim_categories.sql
│       ├── update_dim_customers.sql
│       ├── update_dim_employees.sql
│       ├── update_dim_products.sql
│       ├── update_dim_region.sql
│       ├── update_dim_shippers.sql
│       ├── update_dim_suppliers.sql
│       ├── update_dim_territories.sql
│       ├── update_fact.sql
│       └── update_fact_error.sql
│
├── tests/
│   └── test_utils.py
│
├── main.py
├── utils.py
├── logging.py
├── raw_data_source.xlsx
├── .gitignore
└── README.md
```

---

## Data Source

The project uses the Excel file:

```text
raw_data_source.xlsx
```

The source file contains the following raw tables:

- Categories
- Customers
- Employees
- OrderDetails
- Orders
- Products
- Region
- Shippers
- Suppliers
- Territories

These sheets are loaded into staging tables before being transformed into the dimensional model.

---

## Dimensional Data Store

The dimensional database is named:

```text
ORDER_DDS
```

The database includes staging tables, dimension tables, fact tables, and a source-of-record dimension.

### Main Staging Tables

The staging tables include:

- `staging_categories`
- `staging_customers`
- `staging_employees`
- `staging_order_details`
- `staging_orders`
- `staging_products`
- `staging_region`
- `staging_shippers`
- `staging_suppliers`
- `staging_territories`

Each staging table includes a surrogate staging key:

```text
staging_raw_id_sk
```

### Main Dimension Tables

The dimensional model includes:

- `DimCategories`
- `DimCustomers`
- `DimEmployees`
- `DimProducts`
- `DimRegion`
- `DimShippers`
- `DimSuppliers`
- `DimTerritories`
- `Dim_SOR`

### Fact Tables

The project includes:

- Main fact table
- Fact error table

The fact error table stores rows that cannot be inserted into the fact table because of missing or invalid natural keys.

---

## Pipeline Overview

The dimensional data pipeline is implemented in Python.

The main flow is defined in:

```text
pipeline_dimensional_data/flow.py
```

The pipeline tasks are defined in:

```text
pipeline_dimensional_data/tasks.py
```

The pipeline follows this sequence:

1. Create staging tables.
2. Create dimensional and fact tables.
3. Load Excel sheets into staging tables.
4. Update dimension tables.
5. Update the fact table for the selected date range.
6. Update the fact error table for faulty rows.
7. Write logs for each execution.

Each task returns a success/error dictionary. If a task fails, the pipeline stops and returns the error result.

---

## How to Run the Pipeline

Run the pipeline from the project root folder.

Example:

```bash
python main.py --start_date=2026-01-01 --end_date=2026-12-31
```

The command-line arguments are:

- `--start_date`: start date for fact table ingestion.
- `--end_date`: end date for fact table ingestion.

These parameters are passed into `update_fact.sql` and `update_fact_error.sql`.

---

## SQL Server Configuration

Database connection settings are stored in:

```text
infrastructure_initiation/sql_server_config.cfg
```

Example structure:

```cfg
[sql_server]
server = YOUR_SERVER_NAME
database = ORDER_DDS
driver = ODBC Driver 17 for SQL Server
```

Do not store real passwords or sensitive credentials in the repository.

---

## Infrastructure Scripts

The database and table creation scripts are stored in:

```text
infrastructure_initiation/
```

The main files are:

- `dimensional_database_creation.sql`: creates the `ORDER_DDS` database.
- `staging_raw_table_creation.sql`: creates the raw staging tables.
- `dimensional_db_table_creation.sql`: creates the dimensional tables, fact table, fact error table, and `Dim_SOR`.

---

## Dimension and Fact Update Scripts

The SQL scripts used for updating the dimensional model are stored in:

```text
pipeline_dimensional_data/queries/
```

The dimension update scripts are:

- `update_dim_categories.sql`
- `update_dim_customers.sql`
- `update_dim_employees.sql`
- `update_dim_products.sql`
- `update_dim_region.sql`
- `update_dim_shippers.sql`
- `update_dim_suppliers.sql`
- `update_dim_territories.sql`

The fact update scripts are:

- `update_fact.sql`
- `update_fact_error.sql`

The dimension scripts use placeholders for:

- `{database_name}`
- `{schema_name}`
- `{dimension_table}`
- `{staging_table}`

The fact and fact error scripts use placeholders for:

- `{start_date}`
- `{end_date}`

These placeholders are filled by the Python pipeline before the SQL scripts are executed.

---

## Utility Functions

Common utility functions are stored in:

```text
utils.py
```

The utility functions include:

- Reading SQL files
- Parsing SQL Server configuration
- Creating SQL Server connections
- Executing SQL scripts
- Supporting SQL Server `GO` batch separators
- Generating execution IDs
- Setting up the dimensional data flow logger

---

## Logging

Logging is configured in:

```text
logging.py
```

Pipeline logs are written to:

```text
logs/logs_dimensional_data_pipeline.txt
```

Each pipeline run receives a unique execution ID. This ID is included in the log messages to support tracking and debugging.

Example log format:

```text
2026-05-16 15:40:21 | execution_id=example-uuid | INFO | Pipeline started
```

---

## Testing

Tests are stored in:

```text
tests/test_utils.py
```

Run the tests with:

```bash
pytest tests/test_utils.py
```

The tests use mocking, so they do not require a live SQL Server connection.

The tests cover:

- Execution ID generation
- Logger setup
- Successful mocked SQL Server connection
- Missing SQL Server configuration section
- Database connection failure handling

---

## Power BI Dashboard

The Power BI dashboard file should be stored in:

```text
dashboard/
```

The dashboard is intended to analyze business performance across:

- Sales
- Products
- Categories
- Customers
- Countries
- Employees
- Shippers
- Regions

Suggested dashboard pages include:

1. Executive Overview
2. Product and Category Analysis
3. Customer and Geography Analysis
4. Employee and Shipping Performance

---

## Main Business Questions

The BI dashboard can answer questions such as:

1. What is the total sales revenue?
2. Which product categories generate the most revenue?
3. Which products are the top sellers?
4. Which customers contribute most to sales?
5. Which countries or regions generate the most orders?
6. Which employees are responsible for the highest sales volume?
7. Which shippers are used most frequently?
8. How do sales change over time?

---

## GitHub Contribution Workflow

Each group member should contribute through a separate branch and pull request.

Basic workflow:

```bash
git checkout main
git pull origin main
git checkout -b branch-name
```

After making changes:

```bash
git add .
git commit -m "Meaningful commit message"
git push origin branch-name
```

Then open a Pull Request from the branch into `main`.

---

## Notes

- The SQL scripts in `pipeline_dimensional_data/queries/` are parameterized where needed.
- The fact and fact error scripts use `start_date` and `end_date` parameters.
- Dimension update scripts use placeholders for database name, schema name, dimension table, and staging table.
- The Python pipeline formats the SQL scripts before execution.
- SQL Server `GO` batch separators are handled in the SQL execution utility.
- Python cache files such as `__pycache__/` and `*.pyc` are excluded through `.gitignore`.

---
