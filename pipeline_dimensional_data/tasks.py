import pandas as pd
from utils import get_connection, setup_logger

logger = setup_logger()


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