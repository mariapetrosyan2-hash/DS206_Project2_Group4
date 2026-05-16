import pyodbc
import configparser
import logging
import os
import uuid


def read_sql_file(file_path):
    """
    Reads an SQL script from a .sql file and returns it as a string.
    """
    with open(file_path, "r", encoding="utf-8") as file:
        return file.read()


def parse_sql_server_config(config_path):
    """
    Parses SQL Server configuration from a .cfg file.
    """
    config = configparser.ConfigParser()
    config.read(config_path)

    if "sql_server" not in config:
        raise KeyError("Missing [sql_server] section in config file")

    return {
        "server": config["sql_server"]["server"],
        "database": config["sql_server"]["database"],
        "driver": config["sql_server"]["driver"]
    }


def get_connection():
    """
    Creates and returns a SQL Server database connection.
    """
    base_dir = os.path.dirname(os.path.abspath(__file__))
    config_path = os.path.join(
        base_dir,
        "infrastructure_initiation",
        "sql_server_config.cfg"
    )

    db_config = parse_sql_server_config(config_path)

    server = db_config["server"]
    database = db_config["database"]
    driver = db_config["driver"]

    connection = pyodbc.connect(
        f"DRIVER={{{driver}}};"
        f"SERVER={server};"
        f"DATABASE={database};"
        f"Trusted_Connection=yes;"
    )

    return connection


def execute_sql_script(connection, sql_script):
    """
    Executes a SQL script using the provided database connection.
    """
    cursor = connection.cursor()
    cursor.execute(sql_script)
    connection.commit()

    return {"success": True}


def setup_logger():
    """
    Sets up the logger for the dimensional data pipeline.
    """
    logging.basicConfig(
        filename="logs/logs_dimensional_data_pipeline.txt",
        level=logging.INFO,
        format="%(asctime)s - %(levelname)s - %(message)s"
    )

    return logging


def generate_execution_id():
    """
    Generates a unique execution ID for tracking pipeline runs.
    """
    return str(uuid.uuid4())