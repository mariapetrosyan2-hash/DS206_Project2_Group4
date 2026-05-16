import pyodbc
import configparser
import logging
import os


def get_connection():
    config = configparser.ConfigParser()

    base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    config_path = os.path.join(base_dir, "infrastructure_initiation", "sql_server_config.cfg")

    config.read(config_path)

    server = config["sql_server"]["server"]
    database = config["sql_server"]["database"]
    driver = config["sql_server"]["driver"]

    connection = pyodbc.connect(
        f"DRIVER={{{driver}}};"
        f"SERVER={server};"
        f"DATABASE={database};"
        f"Trusted_Connection=yes;"
    )

    return connection


def setup_logger():
    logging.basicConfig(
        filename='logs/logs_dimensional_data_pipeline.txt',
        level=logging.INFO,
        format='%(asctime)s - %(levelname)s - %(message)s'
    )

    return logging

import uuid

def generate_execution_id():
    return str(uuid.uuid4())