import os
import sys
import uuid
from unittest.mock import MagicMock, patch

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from utils import generate_execution_id, setup_logger, get_connection


def test_generate_execution_id_returns_valid_uuid():
    execution_id = generate_execution_id()

    parsed_uuid = uuid.UUID(execution_id)

    assert str(parsed_uuid) == execution_id


def test_setup_logger_returns_logging_module():
    logger = setup_logger()

    assert hasattr(logger, "info")
    assert hasattr(logger, "error")


@patch("utils.pyodbc.connect")
@patch("utils.configparser.ConfigParser")
def test_get_connection_success(mock_config_parser, mock_pyodbc_connect):
    mock_config = MagicMock()

    mock_config.__contains__.return_value = True

    mock_config.__getitem__.return_value = {
        "server": "localhost,1433",
        "database": "ORDER_DDS",
        "driver": "ODBC Driver 18 for SQL Server",
        "username": "sa",
        "password": "mock_password"
    }

    mock_config_parser.return_value = mock_config

    mock_connection = MagicMock()
    mock_pyodbc_connect.return_value = mock_connection

    connection = get_connection()

    assert connection == mock_connection
    mock_pyodbc_connect.assert_called_once()


@patch("utils.configparser.ConfigParser")
def test_get_connection_missing_sql_server_section(mock_config_parser):
    mock_config = MagicMock()

    mock_config.__contains__.return_value = False

    mock_config_parser.return_value = mock_config

    try:
        get_connection()
        assert False
    except KeyError as error:
        assert "Missing [sql_server] section" in str(error)


@patch("utils.pyodbc.connect")
@patch("utils.configparser.ConfigParser")
def test_get_connection_database_error(mock_config_parser, mock_pyodbc_connect):
    mock_config = MagicMock()

    mock_config.__contains__.return_value = True

    mock_config.__getitem__.return_value = {
        "server": "localhost,1433",
        "database": "ORDER_DDS",
        "driver": "ODBC Driver 18 for SQL Server",
        "username": "sa",
        "password": "mock_password"
    }

    mock_config_parser.return_value = mock_config
    mock_pyodbc_connect.side_effect = Exception("Database connection failed")

    try:
        get_connection()
        assert False
    except Exception as error:
        assert "Database connection failed" in str(error)