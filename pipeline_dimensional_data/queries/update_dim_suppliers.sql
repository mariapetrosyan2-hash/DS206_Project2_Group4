USE ORDER_DDS;

MERGE dbo.DimSuppliers AS target
USING (
    SELECT
        s.SupplierID AS SupplierID_NK,
        s.CompanyName,
        s.ContactName,
        s.ContactTitle,
        s.Address,
        s.City,
        s.Region,
        s.PostalCode,
        s.Country,
        s.Phone,
        s.Fax,
        s.HomePage,
        sor.SOR_SK,
        s.staging_raw_id_sk AS staging_raw_id
    FROM dbo.staging_suppliers s
    INNER JOIN dbo.Dim_SOR sor
        ON sor.SOR_Name = 'Suppliers'
) AS source
ON target.SupplierID_NK = source.SupplierID_NK

WHEN MATCHED THEN
    UPDATE SET
        target.CompanyName = source.CompanyName,
        target.ContactName = source.ContactName,
        target.ContactTitle = source.ContactTitle,
        target.Address = source.Address,
        target.City = source.City,
        target.Region = source.Region,
        target.PostalCode = source.PostalCode,
        target.Country_prior =
            CASE
                WHEN ISNULL(target.Country_current, '') <> ISNULL(source.Country, '')
                THEN target.Country_current
                ELSE target.Country_prior
            END,
        target.Country_current = source.Country,
        target.Phone = source.Phone,
        target.Fax = source.Fax,
        target.HomePage = source.HomePage,
        target.SOR_SK = source.SOR_SK,
        target.staging_raw_id = source.staging_raw_id

WHEN NOT MATCHED THEN
    INSERT (
        SupplierID_NK,
        CompanyName,
        ContactName,
        ContactTitle,
        Address,
        City,
        Region,
        PostalCode,
        Country_current,
        Country_prior,
        Phone,
        Fax,
        HomePage,
        SOR_SK,
        staging_raw_id
    )
    VALUES (
        source.SupplierID_NK,
        source.CompanyName,
        source.ContactName,
        source.ContactTitle,
        source.Address,
        source.City,
        source.Region,
        source.PostalCode,
        source.Country,
        NULL,
        source.Phone,
        source.Fax,
        source.HomePage,
        source.SOR_SK,
        source.staging_raw_id
    );