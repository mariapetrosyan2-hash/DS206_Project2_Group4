USE ORDER_DDS;

MERGE dbo.DimEmployees AS target
USING (
    SELECT
        e.EmployeeID AS EmployeeID_NK,
        e.LastName,
        e.FirstName,
        e.Title,
        e.TitleOfCourtesy,
        e.BirthDate,
        e.HireDate,
        e.Address,
        e.City,
        e.Region,
        e.PostalCode,
        e.Country,
        e.HomePhone,
        e.Extension,
        e.Notes,
        e.ReportsTo,
        e.PhotoPath,
        sor.SOR_SK,
        e.staging_raw_id_sk AS staging_raw_id
    FROM dbo.staging_employees e
    INNER JOIN dbo.Dim_SOR sor
        ON sor.SOR_Name = 'Employees'
    WHERE e.EmployeeID IS NOT NULL
) AS source
ON target.EmployeeID_NK = source.EmployeeID_NK

WHEN MATCHED THEN
    UPDATE SET
        target.LastName = source.LastName,
        target.FirstName = source.FirstName,
        target.Title = source.Title,
        target.TitleOfCourtesy = source.TitleOfCourtesy,
        target.BirthDate = source.BirthDate,
        target.HireDate = source.HireDate,
        target.Address = source.Address,
        target.City = source.City,
        target.Region = source.Region,
        target.PostalCode = source.PostalCode,
        target.Country = source.Country,
        target.HomePhone = source.HomePhone,
        target.Extension = source.Extension,
        target.Notes = source.Notes,
        target.ReportsTo = source.ReportsTo,
        target.PhotoPath = source.PhotoPath,
        target.SOR_SK = source.SOR_SK,
        target.staging_raw_id = source.staging_raw_id,
        target.is_deleted = 0

WHEN NOT MATCHED THEN
    INSERT (
        EmployeeID_NK,
        LastName,
        FirstName,
        Title,
        TitleOfCourtesy,
        BirthDate,
        HireDate,
        Address,
        City,
        Region,
        PostalCode,
        Country,
        HomePhone,
        Extension,
        Notes,
        ReportsTo,
        PhotoPath,
        is_deleted,
        SOR_SK,
        staging_raw_id
    )
    VALUES (
        source.EmployeeID_NK,
        source.LastName,
        source.FirstName,
        source.Title,
        source.TitleOfCourtesy,
        source.BirthDate,
        source.HireDate,
        source.Address,
        source.City,
        source.Region,
        source.PostalCode,
        source.Country,
        source.HomePhone,
        source.Extension,
        source.Notes,
        source.ReportsTo,
        source.PhotoPath,
        0,
        source.SOR_SK,
        source.staging_raw_id
    )

WHEN NOT MATCHED BY SOURCE THEN
    UPDATE SET
        target.is_deleted = 1;