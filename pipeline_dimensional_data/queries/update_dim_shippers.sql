USE {database_name};

MERGE {schema_name}.{dimension_table} AS target
USING (
    SELECT
        s.ShipperID AS ShipperID_NK,
        s.CompanyName,
        s.Phone,
        sor.SOR_SK,
        s.staging_raw_id_sk AS staging_raw_id
    FROM {schema_name}.{staging_table} s
    INNER JOIN {schema_name}.Dim_SOR sor
        ON sor.SOR_Name = 'Shippers'
) AS source
ON target.ShipperID_NK = source.ShipperID_NK

WHEN MATCHED THEN
    UPDATE SET
        target.CompanyName = source.CompanyName,
        target.Phone = source.Phone,
        target.SOR_SK = source.SOR_SK,
        target.staging_raw_id = source.staging_raw_id,
        target.is_deleted = 0

WHEN NOT MATCHED THEN
    INSERT (
        ShipperID_NK,
        CompanyName,
        Phone,
        is_deleted,
        SOR_SK,
        staging_raw_id
    )
    VALUES (
        source.ShipperID_NK,
        source.CompanyName,
        source.Phone,
        0,
        source.SOR_SK,
        source.staging_raw_id
    )

WHEN NOT MATCHED BY SOURCE THEN
    UPDATE SET
        target.is_deleted = 1;