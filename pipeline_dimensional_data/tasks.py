import os
import pandas as pd
from utils import get_connection, setup_logger, read_sql_file, execute_sql_script


logger = setup_logger()


def run_sql_file(file_path, task_name):
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


def create_staging_tables():
    file_path = os.path.join(
        "infrastructure_initiation",
        "staging_raw_table_creation.sql"
    )

    return run_sql_file(file_path, "create_staging_tables")


def create_dimensional_tables():
    file_path = os.path.join(
        "infrastructure_initiation",
        "dimensional_db_table_creation.sql"
    )

    return run_sql_file(file_path, "create_dimensional_tables")


def update_dimension_tables():
    query_folder = os.path.join("pipeline_dimensional_data", "queries")

    dimension_scripts = [
        "update_dim_categories.sql",
        "update_dim_customers.sql",
        "update_dim_employees.sql",
        "update_dim_region.sql",
        "update_dim_suppliers.sql",
        "update_dim_shippers.sql",
        "update_dim_territories.sql",
        "update_dim_products.sql"
    ]

    try:
        logger.info("Starting dimension table update process")

        connection = get_connection()

        for script_name in dimension_scripts:
            file_path = os.path.join(query_folder, script_name)
            sql_script = read_sql_file(file_path)

            logger.info(f"Executing dimension update script: {script_name}")
            execute_sql_script(connection, sql_script)

        connection.close()

        logger.info("Dimension table update process completed successfully")
        return {"success": True, "task": "update_dimension_tables"}

    except Exception as e:
        logger.error(f"Error updating dimension tables: {e}")
        return {"success": False, "task": "update_dimension_tables", "error": str(e)}


def load_excel_to_staging():
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