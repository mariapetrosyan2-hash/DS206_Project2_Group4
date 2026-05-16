import os
from datetime import datetime


class DimensionalLogger:
    def __init__(self, execution_id=None):
        self.execution_id = execution_id if execution_id else "N/A"

        self.log_folder = "logs"
        self.log_file = "logs_dimensional_data_pipeline.txt"

        os.makedirs(self.log_folder, exist_ok=True)

        self.log_path = os.path.join(self.log_folder, self.log_file)

    def _write_log(self, level, message):
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