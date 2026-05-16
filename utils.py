import pyodbc
import configparser
import os
import uuid
import importlib.util


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
        "driver": config["sql_server"]["driver"],
        "username": config["sql_server"]["username"],
        "password": config["sql_server"]["password"]
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
    username = db_config["username"]
    password = db_config["password"]

    connection = pyodbc.connect(
    f"DRIVER={{{driver}}};"
    f"SERVER={server};"
    f"DATABASE={database};"
    f"UID={username};"
    f"PWD={password};"
    f"TrustServerCertificate=yes;"
    )

    return connection


def execute_sql_script(connection, sql_script):
    """
    Executes a SQL script using the provided database connection.
    Supports SQL Server scripts that contain GO batch separators.
    """
    cursor = connection.cursor()

    batches = []
    current_batch = []

    for line in sql_script.splitlines():
        if line.strip().upper() == "GO":
            if current_batch:
                batches.append("\n".join(current_batch))
                current_batch = []
        else:
            current_batch.append(line)

    if current_batch:
        batches.append("\n".join(current_batch))

    for batch in batches:
        if batch.strip():
            cursor.execute(batch)

    connection.commit()

    return {"success": True}


def setup_logger(execution_id=None):
    """
    Loads the project logging.py file and returns a logger
    for the dimensional data pipeline.
    """
    base_dir = os.path.dirname(os.path.abspath(__file__))
    logging_file_path = os.path.join(base_dir, "logging.py")

    spec = importlib.util.spec_from_file_location(
        "project_logging",
        logging_file_path
    )
    project_logging = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(project_logging)

    return project_logging.setup_dimensional_logger(execution_id)

def generate_execution_id():
    """
    Generates a unique execution ID for tracking pipeline runs.
    """
    return str(uuid.uuid4())