USE {database_name};

-- Close changed current product records
UPDATE target
SET
    target.end_date = GETDATE(),
    target.is_current = 0
FROM {schema_name}.{dimension_table} target
INNER JOIN {schema_name}.{staging_table} source
    ON target.ProductID_NK = source.ProductID
LEFT JOIN {schema_name}.DimSuppliers sup
    ON sup.SupplierID_NK = source.SupplierID
LEFT JOIN {schema_name}.DimCategories cat
    ON cat.CategoryID_NK = source.CategoryID
WHERE target.is_current = 1
  AND target.is_deleted = 0
  AND (
        ISNULL(target.ProductName, '') <> ISNULL(source.ProductName, '')
     OR ISNULL(target.SupplierID_SK, -1) <> ISNULL(sup.SupplierID_SK, -1)
     OR ISNULL(target.CategoryID_SK, -1) <> ISNULL(cat.CategoryID_SK, -1)
     OR ISNULL(target.QuantityPerUnit, '') <> ISNULL(source.QuantityPerUnit, '')
     OR ISNULL(target.UnitPrice, -1) <> ISNULL(source.UnitPrice, -1)
     OR ISNULL(target.UnitsInStock, -1) <> ISNULL(source.UnitsInStock, -1)
     OR ISNULL(target.UnitsOnOrder, -1) <> ISNULL(source.UnitsOnOrder, -1)
     OR ISNULL(target.ReorderLevel, -1) <> ISNULL(source.ReorderLevel, -1)
     OR ISNULL(target.Discontinued, 0) <> ISNULL(CAST(source.Discontinued AS BIT), 0)
  );

-- Insert new products or new current versions after changes
INSERT INTO {schema_name}.{dimension_table} (
    ProductID_NK,
    ProductName,
    SupplierID_SK,
    CategoryID_SK,
    QuantityPerUnit,
    UnitPrice,
    UnitsInStock,
    UnitsOnOrder,
    ReorderLevel,
    Discontinued,
    start_date,
    end_date,
    is_current,
    is_deleted,
    SOR_SK,
    staging_raw_id
)
SELECT
    source.ProductID,
    source.ProductName,
    sup.SupplierID_SK,
    cat.CategoryID_SK,
    source.QuantityPerUnit,
    source.UnitPrice,
    source.UnitsInStock,
    source.UnitsOnOrder,
    source.ReorderLevel,
    CAST(source.Discontinued AS BIT),
    GETDATE(),
    NULL,
    1,
    0,
    sor.SOR_SK,
    source.staging_raw_id_sk
FROM {schema_name}.{staging_table} source
INNER JOIN {schema_name}.Dim_SOR sor
    ON sor.SOR_Name = 'Products'
LEFT JOIN {schema_name}.DimSuppliers sup
    ON sup.SupplierID_NK = source.SupplierID
LEFT JOIN {schema_name}.DimCategories cat
    ON cat.CategoryID_NK = source.CategoryID
LEFT JOIN {schema_name}.{dimension_table} current_target
    ON current_target.ProductID_NK = source.ProductID
   AND current_target.is_current = 1
   AND current_target.is_deleted = 0
WHERE current_target.ProductID_SK IS NULL;

-- Mark products deleted if they no longer exist in staging
UPDATE target
SET
    target.end_date = GETDATE(),
    target.is_current = 0,
    target.is_deleted = 1
FROM {schema_name}.{dimension_table} target
LEFT JOIN {schema_name}.{staging_table} source
    ON target.ProductID_NK = source.ProductID
WHERE source.ProductID IS NULL
  AND target.is_current = 1
  AND target.is_deleted = 0;