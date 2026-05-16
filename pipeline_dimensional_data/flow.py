from utils import setup_logger, generate_execution_id
from pipeline_dimensional_data.tasks import (
    create_staging_tables,
    create_dimensional_tables,
    load_excel_to_staging,
    update_dimension_tables,
    update_fact_table,
    update_fact_error_table
)


class DimensionalDataFlow:
    def __init__(self):
        self.execution_id = generate_execution_id()
        self.logger = setup_logger(self.execution_id)

    def exec(self, start_date=None, end_date=None):
        self.logger.info("Pipeline started")
        self.logger.info(f"Start date: {start_date}, End date: {end_date}")

        staging_tables_result = create_staging_tables(self.execution_id)

        if not staging_tables_result["success"]:
            self.logger.error(
                f"Pipeline failed at create_staging_tables: "
                f"{staging_tables_result['error']}"
            )
            return staging_tables_result

        self.logger.info("Staging tables created successfully")

        dimensional_tables_result = create_dimensional_tables(self.execution_id)

        if not dimensional_tables_result["success"]:
            self.logger.error(
                f"Pipeline failed at create_dimensional_tables: "
                f"{dimensional_tables_result['error']}"
            )
            return dimensional_tables_result

        self.logger.info("Dimensional tables created successfully")

        staging_load_result = load_excel_to_staging(self.execution_id)

        if not staging_load_result["success"]:
            self.logger.error(
                f"Pipeline failed at load_excel_to_staging: "
                f"{staging_load_result['error']}"
            )
            return staging_load_result

        self.logger.info("Excel data loaded into staging successfully")

        dimension_update_result = update_dimension_tables(self.execution_id)

        if not dimension_update_result["success"]:
            self.logger.error(
                f"Pipeline failed at update_dimension_tables: "
                f"{dimension_update_result['error']}"
            )
            return dimension_update_result

        self.logger.info("Dimension tables updated successfully")

        fact_update_result = update_fact_table(start_date, end_date, self.execution_id)

        if not fact_update_result["success"]:
            self.logger.error(
                f"Pipeline failed at update_fact_table: "
                f"{fact_update_result['error']}"
            )
            return fact_update_result

        self.logger.info("Fact table updated successfully")

        fact_error_update_result = update_fact_error_table(start_date, end_date, self.execution_id)

        if not fact_error_update_result["success"]:
            self.logger.error(
                f"Pipeline failed at update_fact_error_table: "
                f"{fact_error_update_result['error']}"
            )
            return fact_error_update_result

        self.logger.info("Fact error table updated successfully")
        self.logger.info("Pipeline completed successfully")

        return {"success": True, "execution_id": self.execution_id}