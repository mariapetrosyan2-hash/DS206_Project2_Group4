from utils import setup_logger, generate_execution_id
from pipeline_dimensional_data.tasks import (
    create_staging_tables,
    create_dimensional_tables,
    load_excel_to_staging,
    update_dimension_tables
)


logger = setup_logger()


class DimensionalDataFlow:
    def __init__(self):
        self.execution_id = generate_execution_id()

    def exec(self, start_date=None, end_date=None):
        logger.info(f"[{self.execution_id}] Pipeline started")
        logger.info(f"[{self.execution_id}] Start date: {start_date}, End date: {end_date}")

        staging_tables_result = create_staging_tables()

        if not staging_tables_result["success"]:
            logger.error(
                f"[{self.execution_id}] Pipeline failed at create_staging_tables: "
                f"{staging_tables_result['error']}"
            )
            return staging_tables_result

        logger.info(f"[{self.execution_id}] Staging tables created successfully")

        dimensional_tables_result = create_dimensional_tables()

        if not dimensional_tables_result["success"]:
            logger.error(
                f"[{self.execution_id}] Pipeline failed at create_dimensional_tables: "
                f"{dimensional_tables_result['error']}"
            )
            return dimensional_tables_result

        logger.info(f"[{self.execution_id}] Dimensional tables created successfully")

        staging_load_result = load_excel_to_staging()

        if not staging_load_result["success"]:
            logger.error(
                f"[{self.execution_id}] Pipeline failed at load_excel_to_staging: "
                f"{staging_load_result['error']}"
            )
            return staging_load_result

        logger.info(f"[{self.execution_id}] Excel data loaded into staging successfully")

        dimension_update_result = update_dimension_tables()

        if not dimension_update_result["success"]:
            logger.error(
                f"[{self.execution_id}] Pipeline failed at update_dimension_tables: "
                f"{dimension_update_result['error']}"
            )
            return dimension_update_result

        logger.info(f"[{self.execution_id}] Dimension tables updated successfully")

        logger.info(f"[{self.execution_id}] Pipeline completed successfully")

        return {"success": True, "execution_id": self.execution_id}