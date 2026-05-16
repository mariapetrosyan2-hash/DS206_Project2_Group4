import os
import sysconfig
import importlib.util


# Load Python's real built-in logging module from the standard library.
# This avoids breaking libraries like pandas/cloudpickle that expect logging.Logger.
stdlib_path = sysconfig.get_paths()["stdlib"]
real_logging_path = os.path.join(stdlib_path, "logging", "__init__.py")

spec = importlib.util.spec_from_file_location("_real_python_logging", real_logging_path)
_real_logging = importlib.util.module_from_spec(spec)
spec.loader.exec_module(_real_logging)

# Expose all standard logging module attributes through this file.
# This makes this project logging.py behave like the real logging module too.
for name in dir(_real_logging):
    if not name.startswith("__"):
        globals()[name] = getattr(_real_logging, name)


class DimensionalLogger:
    def __init__(self, execution_id=None):
        self.execution_id = execution_id if execution_id else "N/A"

        self.log_folder = "logs"
        self.log_file = "logs_dimensional_data_pipeline.txt"

        os.makedirs(self.log_folder, exist_ok=True)

        self.log_path = os.path.join(self.log_folder, self.log_file)

    def _write_log(self, level, message):
        from datetime import datetime

        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

        log_message = (
            f"{timestamp} | "
            f"execution_id={self.execution_id} | "
            f"{level} | "
            f"{message}\n"
        )

        with open(self.log_path, "a", encoding="utf-8") as log_file:
            log_file.write(log_message)

    def info(self, message):
        self._write_log("INFO", message)

    def error(self, message):
        self._write_log("ERROR", message)


def setup_dimensional_logger(execution_id=None):
    return DimensionalLogger(execution_id)