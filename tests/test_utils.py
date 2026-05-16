import sys
import os

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from pipeline_dimensional_data.utils import get_connection


def test_sql_connection():
    connection = get_connection()
    assert connection is not None
    connection.close()