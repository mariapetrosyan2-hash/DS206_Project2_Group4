USE {database_name};

MERGE {schema_name}.{dimension_table} AS target
USING (
    SELECT
        c.CategoryID AS CategoryID_NK,
        c.CategoryName,
        c.Description,
        sor.SOR_SK,
        c.staging_raw_id_sk AS staging_raw_id
    FROM {schema_name}.{staging_table} c
    INNER JOIN {schema_name}.Dim_SOR sor
        ON sor.SOR_Name = 'Categories'
) AS source
ON target.CategoryID_NK = source.CategoryID_NK

WHEN MATCHED THEN
    UPDATE SET
        target.CategoryName = source.CategoryName,
        target.Description = source.Description,
        target.SOR_SK = source.SOR_SK,
        target.staging_raw_id = source.staging_raw_id

WHEN NOT MATCHED THEN
    INSERT (
        CategoryID_NK,
        CategoryName,
        Description,
        SOR_SK,
        staging_raw_id
    )
    VALUES (
        source.CategoryID_NK,
        source.CategoryName,
        source.Description,
        source.SOR_SK,
        source.staging_raw_id
    );