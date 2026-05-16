from utils import setup_logger, generate_execution_id
from tasks import load_excel_to_staging

logger = setup_logger()


class DimensionalDataFlow:
    def __init__(self):
        self.execution_id = generate_execution_id()

    def exec(self, start_date=None, end_date=None):
        logger.info(f"[{self.execution_id}] Pipeline started")
        logger.info(f"[{self.execution_id}] Start date: {start_date}, End date: {end_date}")

        staging_result = load_excel_to_staging()

        if not staging_result["success"]:
            logger.error(f"[{self.execution_id}] Pipeline failed: {staging_result['error']}")
            return staging_result

        logger.info(f"[{self.execution_id}] Staging task completed successfully")
        logger.info(f"[{self.execution_id}] Pipeline completed successfully")

        return {"success": True, "execution_id": self.execution_id}