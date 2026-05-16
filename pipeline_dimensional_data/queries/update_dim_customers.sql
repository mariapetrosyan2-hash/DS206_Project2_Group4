USE {database_name};

-- Close old current records when customer attributes changed
UPDATE target
SET
    target.end_date = GETDATE(),
    target.is_current = 0
FROM {schema_name}.{dimension_table} target
INNER JOIN {schema_name}.{staging_table} source
    ON target.CustomerID_NK = source.CustomerID
WHERE target.is_current = 1
  AND (
        ISNULL(target.CompanyName, '') <> ISNULL(source.CompanyName, '')
     OR ISNULL(target.ContactName, '') <> ISNULL(source.ContactName, '')
     OR ISNULL(target.ContactTitle, '') <> ISNULL(source.ContactTitle, '')
     OR ISNULL(target.Address, '') <> ISNULL(source.Address, '')
     OR ISNULL(target.City, '') <> ISNULL(source.City, '')
     OR ISNULL(target.Region, '') <> ISNULL(source.Region, '')
     OR ISNULL(target.PostalCode, '') <> ISNULL(source.PostalCode, '')
     OR ISNULL(target.Country, '') <> ISNULL(source.Country, '')
     OR ISNULL(target.Phone, '') <> ISNULL(source.Phone, '')
     OR ISNULL(target.Fax, '') <> ISNULL(source.Fax, '')
  );

-- Insert new customers or new current versions after change
INSERT INTO {schema_name}.{dimension_table} (
    CustomerID_NK,
    CompanyName,
    ContactName,
    ContactTitle,
    Address,
    City,
    Region,
    PostalCode,
    Country,
    Phone,
    Fax,
    start_date,
    end_date,
    is_current,
    SOR_SK,
    staging_raw_id
)
SELECT
    source.CustomerID,
    source.CompanyName,
    source.ContactName,
    source.ContactTitle,
    source.Address,
    source.City,
    source.Region,
    source.PostalCode,
    source.Country,
    source.Phone,
    source.Fax,
    GETDATE() AS start_date,
    NULL AS end_date,
    1 AS is_current,
    sor.SOR_SK,
    source.staging_raw_id_sk AS staging_raw_id
FROM {schema_name}.{staging_table} source
INNER JOIN {schema_name}.Dim_SOR sor
    ON sor.SOR_Name = 'Customers'
LEFT JOIN {schema_name}.{dimension_table} current_target
    ON current_target.CustomerID_NK = source.CustomerID
   AND current_target.is_current = 1
WHERE current_target.CustomerID_SK IS NULL;