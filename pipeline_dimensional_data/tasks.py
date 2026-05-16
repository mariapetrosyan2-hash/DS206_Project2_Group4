import os
import pandas as pd
from utils import get_connection, setup_logger, read_sql_file, execute_sql_script


def run_sql_file(file_path, task_name, execution_id=None):
    logger = setup_logger(execution_id)

    try:
        logger.info(f"Starting task: {task_name}")

        connection = get_connection()
        sql_script = read_sql_file(file_path)

        result = execute_sql_script(connection, sql_script)

        connection.close()

        logger.info(f"Completed task: {task_name}")
        return {"success": True, "task": task_name, "result": result}

    except Exception as e:
        logger.error(f"Error in task {task_name}: {e}")
        return {"success": False, "task": task_name, "error": str(e)}


def create_staging_tables(execution_id=None):
    file_path = os.path.join(
        "infrastructure_initiation",
        "staging_raw_table_creation.sql"
    )

    return run_sql_file(file_path, "create_staging_tables", execution_id)


def create_dimensional_tables(execution_id=None):
    file_path = os.path.join(
        "infrastructure_initiation",
        "dimensional_db_table_creation.sql"
    )

    return run_sql_file(file_path, "create_dimensional_tables", execution_id)


def update_dimension_tables(execution_id=None):
    logger = setup_logger(execution_id)
    query_folder = os.path.join("pipeline_dimensional_data", "queries")

    dimension_scripts = [
        {
            "script": "update_dim_categories.sql",
            "dimension_table": "DimCategories",
            "staging_table": "staging_categories"
        },
        {
            "script": "update_dim_customers.sql",
            "dimension_table": "DimCustomers",
            "staging_table": "staging_customers"
        },
        {
            "script": "update_dim_employees.sql",
            "dimension_table": "DimEmployees",
            "staging_table": "staging_employees"
        },
        {
            "script": "update_dim_region.sql",
            "dimension_table": "DimRegion",
            "staging_table": "staging_region"
        },
        {
            "script": "update_dim_suppliers.sql",
            "dimension_table": "DimSuppliers",
            "staging_table": "staging_suppliers"
        },
        {
            "script": "update_dim_shippers.sql",
            "dimension_table": "DimShippers",
            "staging_table": "staging_shippers"
        },
        {
            "script": "update_dim_territories.sql",
            "dimension_table": "DimTerritories",
            "staging_table": "staging_territories"
        },
        {
            "script": "update_dim_products.sql",
            "dimension_table": "DimProducts",
            "staging_table": "staging_products"
        }
    ]

    try:
        logger.info("Starting dimension table update process")

        connection = get_connection()

        for script_config in dimension_scripts:
            file_path = os.path.join(query_folder, script_config["script"])
            sql_script = read_sql_file(file_path)

            sql_script = sql_script.format(
                database_name="ORDER_DDS",
                schema_name="dbo",
                dimension_table=script_config["dimension_table"],
                staging_table=script_config["staging_table"]
            )

            logger.info(f"Executing dimension update script: {script_config['script']}")
            execute_sql_script(connection, sql_script)

        connection.close()

        logger.info("Dimension table update process completed successfully")
        return {"success": True, "task": "update_dimension_tables"}

    except Exception as e:
        logger.error(f"Error updating dimension tables: {e}")
        return {"success": False, "task": "update_dimension_tables", "error": str(e)}


def update_fact_table(start_date=None, end_date=None, execution_id=None):
    logger = setup_logger(execution_id)
    file_path = os.path.join(
        "pipeline_dimensional_data",
        "queries",
        "update_fact.sql"
    )

    try:
        logger.info("Starting fact table update process")

        connection = get_connection()
        sql_script = read_sql_file(file_path)

        sql_script = sql_script.format(
            start_date=start_date,
            end_date=end_date
        )

        logger.info("Executing fact update script")
        execute_sql_script(connection, sql_script)

        connection.close()

        logger.info("Fact table update process completed successfully")
        return {"success": True, "task": "update_fact_table"}

    except Exception as e:
        logger.error(f"Error updating fact table: {e}")
        return {"success": False, "task": "update_fact_table", "error": str(e)}


def update_fact_error_table(start_date=None, end_date=None, execution_id=None):
    logger = setup_logger(execution_id)
    file_path = os.path.join(
        "pipeline_dimensional_data",
        "queries",
        "update_fact_error.sql"
    )

    try:
        logger.info("Starting fact error table update process")

        connection = get_connection()
        sql_script = read_sql_file(file_path)

        sql_script = sql_script.format(
            start_date=start_date,
            end_date=end_date
        )

        logger.info("Executing fact error update script")
        execute_sql_script(connection, sql_script)

        connection.close()

        logger.info("Fact error table update process completed successfully")
        return {"success": True, "task": "update_fact_error_table"}

    except Exception as e:
        logger.error(f"Error updating fact error table: {e}")
        return {"success": False, "task": "update_fact_error_table", "error": str(e)}


def load_excel_to_staging(execution_id=None):
    logger = setup_logger(execution_id)
    try:
        logger.info("Starting Excel load process")

        connection = get_connection()
        excel_file = "raw_data_source.xlsx"

        table_mapping = {
            "Categories": "staging_categories",
            "Customers": "staging_customers",
            "Employees": "staging_employees",
            "OrderDetails": "staging_order_details",
            "Orders": "staging_orders",
            "Products": "staging_products",
            "Region": "staging_region",
            "Shippers": "staging_shippers",
            "Suppliers": "staging_suppliers",
            "Territories": "staging_territories"
        }

        xls = pd.ExcelFile(excel_file)

        for sheet_name in xls.sheet_names:
            df = pd.read_excel(excel_file, sheet_name=sheet_name)
            df = df.where(pd.notnull(df), None)

            table_name = table_mapping[sheet_name]
            cursor = connection.cursor()

            for _, row in df.iterrows():
                placeholders = ",".join(["?"] * len(row))

                query = f"""
                INSERT INTO {table_name}
                VALUES ({placeholders})
                """

                clean_row = tuple(None if pd.isna(value) else value for value in row)
                cursor.execute(query, clean_row)

            connection.commit()
            logger.info(f"Loaded sheet: {sheet_name}")

        connection.close()
        logger.info("Excel load completed successfully")

        return {"success": True, "task": "load_excel_to_staging"}

    except Exception as e:
        logger.error(f"Error loading Excel data: {e}")
        return {"success": False, "task": "load_excel_to_staging", "error": str(e)}