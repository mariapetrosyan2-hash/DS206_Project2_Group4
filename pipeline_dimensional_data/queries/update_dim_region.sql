USE ORDER_DDS;
GO

-- Insert new regions into the main SCD4 current table
INSERT INTO dbo.DimRegion (
    RegionID_NK,
    RegionDescription,
    RegionCategory,
    RegionImportance,
    SOR_SK,
    staging_raw_id
)
SELECT
    source.RegionID,
    source.RegionDescription,
    source.RegionCategory,
    source.RegionImportance,
    sor.SOR_SK,
    source.staging_raw_id_sk
FROM dbo.staging_region source
INNER JOIN dbo.Dim_SOR sor
    ON sor.SOR_Name = 'Region'
LEFT JOIN dbo.DimRegion target
    ON target.RegionID_NK = source.RegionID
WHERE target.RegionID_SK IS NULL;

-- Close old history rows when region attributes changed
UPDATE history
SET
    history.end_date = GETDATE(),
    history.is_current = 0
FROM dbo.DimRegion_History history
INNER JOIN dbo.DimRegion dim
    ON history.RegionID_SK = dim.RegionID_SK
INNER JOIN dbo.staging_region source
    ON dim.RegionID_NK = source.RegionID
WHERE history.is_current = 1
  AND (
        ISNULL(history.RegionDescription, '') <> ISNULL(source.RegionDescription, '')
     OR ISNULL(history.RegionCategory, '') <> ISNULL(source.RegionCategory, '')
     OR ISNULL(history.RegionImportance, '') <> ISNULL(source.RegionImportance, '')
  );

-- Update main current table
UPDATE target
SET
    target.RegionDescription = source.RegionDescription,
    target.RegionCategory = source.RegionCategory,
    target.RegionImportance = source.RegionImportance,
    target.SOR_SK = sor.SOR_SK,
    target.staging_raw_id = source.staging_raw_id_sk
FROM dbo.DimRegion target
INNER JOIN dbo.staging_region source
    ON target.RegionID_NK = source.RegionID
INNER JOIN dbo.Dim_SOR sor
    ON sor.SOR_Name = 'staging_region';

-- Insert new current history rows
INSERT INTO dbo.DimRegion_History (
    RegionID_SK,
    RegionID_NK,
    RegionDescription,
    RegionCategory,
    RegionImportance,
    start_date,
    end_date,
    is_current,
    SOR_SK,
    staging_raw_id
)
SELECT
    dim.RegionID_SK,
    dim.RegionID_NK,
    dim.RegionDescription,
    dim.RegionCategory,
    dim.RegionImportance,
    GETDATE(),
    NULL,
    1,
    dim.SOR_SK,
    dim.staging_raw_id
FROM dbo.DimRegion dim
LEFT JOIN dbo.DimRegion_History history
    ON history.RegionID_SK = dim.RegionID_SK
   AND history.is_current = 1
WHERE history.RegionHistory_SK IS NULL;