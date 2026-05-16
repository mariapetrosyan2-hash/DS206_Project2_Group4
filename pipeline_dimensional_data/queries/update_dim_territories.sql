USE {database_name};

-- Insert new territories into the main SCD4 current table
INSERT INTO {schema_name}.{dimension_table} (
    TerritoryID_NK,
    TerritoryDescription,
    TerritoryCode,
    RegionID_SK,
    SOR_SK,
    staging_raw_id
)
SELECT
    source.TerritoryID,
    source.TerritoryDescription,
    source.TerritoryCode,
    region.RegionID_SK,
    sor.SOR_SK,
    source.staging_raw_id_sk
FROM {schema_name}.{staging_table} source
INNER JOIN {schema_name}.Dim_SOR sor
    ON sor.SOR_Name = 'Territories'
LEFT JOIN {schema_name}.DimRegion region
    ON region.RegionID_NK = source.RegionID
LEFT JOIN {schema_name}.{dimension_table} target
    ON target.TerritoryID_NK = source.TerritoryID
WHERE target.TerritoryID_SK IS NULL;

-- Close old history rows when territory attributes changed
UPDATE history
SET
    history.end_date = GETDATE(),
    history.is_current = 0
FROM {schema_name}.DimTerritories_History history
INNER JOIN {schema_name}.{dimension_table} dim
    ON history.TerritoryID_SK = dim.TerritoryID_SK
INNER JOIN {schema_name}.{staging_table} source
    ON dim.TerritoryID_NK = source.TerritoryID
LEFT JOIN {schema_name}.DimRegion region
    ON region.RegionID_NK = source.RegionID
WHERE history.is_current = 1
  AND (
        ISNULL(history.TerritoryDescription, '') <> ISNULL(source.TerritoryDescription, '')
     OR ISNULL(history.TerritoryCode, '') <> ISNULL(source.TerritoryCode, '')
     OR ISNULL(history.RegionID_SK, -1) <> ISNULL(region.RegionID_SK, -1)
  );

-- Update main current table
UPDATE target
SET
    target.TerritoryDescription = source.TerritoryDescription,
    target.TerritoryCode = source.TerritoryCode,
    target.RegionID_SK = region.RegionID_SK,
    target.SOR_SK = sor.SOR_SK,
    target.staging_raw_id = source.staging_raw_id_sk
FROM {schema_name}.{dimension_table} target
INNER JOIN {schema_name}.{staging_table} source
    ON target.TerritoryID_NK = source.TerritoryID
INNER JOIN {schema_name}.Dim_SOR sor
    ON sor.SOR_Name = 'Territories'
LEFT JOIN {schema_name}.DimRegion region
    ON region.RegionID_NK = source.RegionID;

-- Insert new current history rows
INSERT INTO {schema_name}.DimTerritories_History (
    TerritoryID_SK,
    TerritoryID_NK,
    TerritoryDescription,
    TerritoryCode,
    RegionID_SK,
    start_date,
    end_date,
    is_current,
    SOR_SK,
    staging_raw_id
)
SELECT
    dim.TerritoryID_SK,
    dim.TerritoryID_NK,
    dim.TerritoryDescription,
    dim.TerritoryCode,
    dim.RegionID_SK,
    GETDATE(),
    NULL,
    1,
    dim.SOR_SK,
    dim.staging_raw_id
FROM {schema_name}.{dimension_table} dim
LEFT JOIN {schema_name}.DimTerritories_History history
    ON history.TerritoryID_SK = dim.TerritoryID_SK
   AND history.is_current = 1
WHERE history.TerritoryHistory_SK IS NULL;