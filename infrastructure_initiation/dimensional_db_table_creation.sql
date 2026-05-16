USE ORDER_DDS;
GO

CREATE TABLE dbo.Dim_SOR (
    SOR_SK         INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    SOR_Name       NVARCHAR(100)     NOT NULL UNIQUE
);
GO

CREATE TABLE dbo.DimCategories (
    CategoryID_SK   INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    CategoryID_NK   INT               NOT NULL,
    CategoryName    NVARCHAR(50)      NULL,
    Description     NVARCHAR(MAX)     NULL,
    SOR_SK          INT               NOT NULL,
    staging_raw_id  INT               NOT NULL,
    CONSTRAINT FK_DimCategories_SOR
        FOREIGN KEY (SOR_SK) REFERENCES dbo.Dim_SOR(SOR_SK)
);
GO

CREATE TABLE dbo.DimCustomers (
    CustomerID_SK   INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    CustomerID_NK   NCHAR(5)          NOT NULL,
    CompanyName     NVARCHAR(100)     NULL,
    ContactName     NVARCHAR(100)     NULL,
    ContactTitle    NVARCHAR(50)      NULL,
    Address         NVARCHAR(150)     NULL,
    City            NVARCHAR(50)      NULL,
    Region          NVARCHAR(50)      NULL,
    PostalCode      NVARCHAR(20)      NULL,
    Country         NVARCHAR(50)      NULL,
    Phone           NVARCHAR(30)      NULL,
    Fax             NVARCHAR(30)      NULL,
    start_date      DATETIME          NOT NULL,
    end_date        DATETIME          NULL,
    is_current      BIT               NOT NULL DEFAULT 1,
    SOR_SK          INT               NOT NULL,
    staging_raw_id  INT               NOT NULL,
    CONSTRAINT FK_DimCustomers_SOR
        FOREIGN KEY (SOR_SK) REFERENCES dbo.Dim_SOR(SOR_SK)
);
GO

CREATE TABLE dbo.DimEmployees (
    EmployeeID_SK     INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    EmployeeID_NK     INT               NOT NULL,
    LastName          NVARCHAR(50)      NULL,
    FirstName         NVARCHAR(50)      NULL,
    Title             NVARCHAR(50)      NULL,
    TitleOfCourtesy   NVARCHAR(25)      NULL,
    BirthDate         DATETIME          NULL,
    HireDate          DATETIME          NULL,
    Address           NVARCHAR(150)     NULL,
    City              NVARCHAR(50)      NULL,
    Region            NVARCHAR(50)      NULL,
    PostalCode        NVARCHAR(20)      NULL,
    Country           NVARCHAR(50)      NULL,
    HomePhone         NVARCHAR(30)      NULL,
    Extension         NVARCHAR(10)      NULL,
    Notes             NVARCHAR(MAX)     NULL,
    ReportsTo         INT               NULL,
    PhotoPath         NVARCHAR(255)     NULL,
    is_deleted        BIT               NOT NULL DEFAULT 0,
    SOR_SK            INT               NOT NULL,
    staging_raw_id    INT               NOT NULL,
    CONSTRAINT FK_DimEmployees_SOR
        FOREIGN KEY (SOR_SK) REFERENCES dbo.Dim_SOR(SOR_SK)
);
GO

CREATE TABLE dbo.DimShippers (
    ShipperID_SK    INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    ShipperID_NK    INT               NOT NULL,
    CompanyName     NVARCHAR(100)     NULL,
    Phone           NVARCHAR(30)      NULL,
    is_deleted      BIT               NOT NULL DEFAULT 0,
    SOR_SK          INT               NOT NULL,
    staging_raw_id  INT               NOT NULL,
    CONSTRAINT FK_DimShippers_SOR
        FOREIGN KEY (SOR_SK) REFERENCES dbo.Dim_SOR(SOR_SK)
);
GO


CREATE TABLE dbo.DimSuppliers (
    SupplierID_SK   INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    SupplierID_NK   INT               NOT NULL,
    CompanyName     NVARCHAR(100)     NULL,
    ContactName     NVARCHAR(100)     NULL,
    ContactTitle    NVARCHAR(50)      NULL,
    Address         NVARCHAR(150)     NULL,
    City            NVARCHAR(50)      NULL,
    Region          NVARCHAR(50)      NULL,
    PostalCode      NVARCHAR(20)      NULL,
    Country_current NVARCHAR(50)      NULL,   -- SCD3 tracked attribute (current)
    Country_prior   NVARCHAR(50)      NULL,   -- SCD3 tracked attribute (prior)
    Phone           NVARCHAR(30)      NULL,
    Fax             NVARCHAR(30)      NULL,
    HomePage        NVARCHAR(MAX)     NULL,
    SOR_SK          INT               NOT NULL,
    staging_raw_id  INT               NOT NULL,
    CONSTRAINT FK_DimSuppliers_SOR
        FOREIGN KEY (SOR_SK) REFERENCES dbo.Dim_SOR(SOR_SK)
);
GO

CREATE TABLE dbo.DimRegion (
    RegionID_SK       INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    RegionID_NK       INT               NOT NULL,
    RegionDescription NVARCHAR(50)      NULL,
    RegionCategory    NVARCHAR(50)      NULL,
    RegionImportance  NVARCHAR(50)      NULL,
    SOR_SK            INT               NOT NULL,
    staging_raw_id    INT               NOT NULL,
    CONSTRAINT FK_DimRegion_SOR
        FOREIGN KEY (SOR_SK) REFERENCES dbo.Dim_SOR(SOR_SK)
);
GO

CREATE TABLE dbo.DimRegion_History (
    RegionHistory_SK  INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    RegionID_SK       INT               NOT NULL,
    RegionID_NK       INT               NOT NULL,
    RegionDescription NVARCHAR(50)      NULL,
    RegionCategory    NVARCHAR(50)      NULL,
    RegionImportance  NVARCHAR(50)      NULL,
    start_date        DATETIME          NOT NULL,
    end_date          DATETIME          NULL,
    is_current        BIT               NOT NULL DEFAULT 1,
    SOR_SK            INT               NOT NULL,
    staging_raw_id    INT               NOT NULL,
    CONSTRAINT FK_DimRegionHistory_DimRegion
        FOREIGN KEY (RegionID_SK) REFERENCES dbo.DimRegion(RegionID_SK),
    CONSTRAINT FK_DimRegionHistory_SOR
        FOREIGN KEY (SOR_SK) REFERENCES dbo.Dim_SOR(SOR_SK)
);
GO

CREATE TABLE dbo.DimTerritories (
    TerritoryID_SK       INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    TerritoryID_NK       NVARCHAR(20)      NOT NULL,
    TerritoryDescription NVARCHAR(100)     NULL,
    TerritoryCode        NVARCHAR(20)      NULL,
    RegionID_SK          INT               NULL,
    SOR_SK               INT               NOT NULL,
    staging_raw_id       INT               NOT NULL,
    CONSTRAINT FK_DimTerritories_DimRegion
        FOREIGN KEY (RegionID_SK) REFERENCES dbo.DimRegion(RegionID_SK),
    CONSTRAINT FK_DimTerritories_SOR
        FOREIGN KEY (SOR_SK) REFERENCES dbo.Dim_SOR(SOR_SK)
);
GO

CREATE TABLE dbo.DimTerritories_History (
    TerritoryHistory_SK  INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    TerritoryID_SK       INT               NOT NULL,
    TerritoryID_NK       NVARCHAR(20)      NOT NULL,
    TerritoryDescription NVARCHAR(100)     NULL,
    TerritoryCode        NVARCHAR(20)      NULL,
    RegionID_SK          INT               NULL,
    start_date           DATETIME          NOT NULL,
    end_date             DATETIME          NULL,
    is_current           BIT               NOT NULL DEFAULT 1,
    SOR_SK               INT               NOT NULL,
    staging_raw_id       INT               NOT NULL,
    CONSTRAINT FK_DimTerritoriesHistory_DimTerritories
        FOREIGN KEY (TerritoryID_SK) REFERENCES dbo.DimTerritories(TerritoryID_SK),
    CONSTRAINT FK_DimTerritoriesHistory_SOR
        FOREIGN KEY (SOR_SK) REFERENCES dbo.Dim_SOR(SOR_SK)
);
GO


CREATE TABLE dbo.DimProducts (
    ProductID_SK     INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    ProductID_NK     INT               NOT NULL,
    ProductName      NVARCHAR(100)     NULL,
    SupplierID_SK    INT               NULL,
    CategoryID_SK    INT               NULL,
    QuantityPerUnit  NVARCHAR(50)      NULL,
    UnitPrice        DECIMAL(18,4)     NULL,
    UnitsInStock     SMALLINT          NULL,
    UnitsOnOrder     SMALLINT          NULL,
    ReorderLevel     SMALLINT          NULL,
    Discontinued     BIT               NULL,
    start_date       DATETIME          NOT NULL,
    end_date         DATETIME          NULL,
    is_current       BIT               NOT NULL DEFAULT 1,
    is_deleted       BIT               NOT NULL DEFAULT 0,
    SOR_SK           INT               NOT NULL,
    staging_raw_id   INT               NOT NULL,
    CONSTRAINT FK_DimProducts_DimSuppliers
        FOREIGN KEY (SupplierID_SK) REFERENCES dbo.DimSuppliers(SupplierID_SK),
    CONSTRAINT FK_DimProducts_DimCategories
        FOREIGN KEY (CategoryID_SK) REFERENCES dbo.DimCategories(CategoryID_SK),
    CONSTRAINT FK_DimProducts_SOR
        FOREIGN KEY (SOR_SK) REFERENCES dbo.Dim_SOR(SOR_SK)
);
GO

CREATE TABLE dbo.FactOrders (
    FactOrders_SK             INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    OrderID_NK                INT               NOT NULL,
    ProductID_NK              INT               NOT NULL,
    CustomerID_SK             INT               NULL,
    EmployeeID_SK             INT               NULL,
    ProductID_SK              INT               NULL,
    ShipperID_SK              INT               NULL,
    TerritoryID_SK            INT               NULL,
    OrderDate                 DATETIME          NULL,
    RequiredDate              DATETIME          NULL,
    ShippedDate               DATETIME          NULL,
    UnitPrice                 DECIMAL(18,4)     NULL,
    Quantity                  SMALLINT          NULL,
    Discount                  REAL              NULL,
    LineTotal                 AS (CAST(UnitPrice * Quantity * (1 - Discount) AS DECIMAL(18,4))) PERSISTED,
    Freight                   DECIMAL(18,4)     NULL,
    SOR_SK_orders             INT               NOT NULL,
    SOR_SK_orderdetails       INT               NOT NULL,
    staging_raw_id_orders     INT               NOT NULL,
    staging_raw_id_orderdtls  INT               NOT NULL,
    load_date                 DATETIME          NOT NULL DEFAULT GETDATE(),

    CONSTRAINT FK_FactOrders_DimCustomers
        FOREIGN KEY (CustomerID_SK)  REFERENCES dbo.DimCustomers(CustomerID_SK),
    CONSTRAINT FK_FactOrders_DimEmployees
        FOREIGN KEY (EmployeeID_SK)  REFERENCES dbo.DimEmployees(EmployeeID_SK),
    CONSTRAINT FK_FactOrders_DimProducts
        FOREIGN KEY (ProductID_SK)   REFERENCES dbo.DimProducts(ProductID_SK),
    CONSTRAINT FK_FactOrders_DimShippers
        FOREIGN KEY (ShipperID_SK)   REFERENCES dbo.DimShippers(ShipperID_SK),
    CONSTRAINT FK_FactOrders_DimTerritories
        FOREIGN KEY (TerritoryID_SK) REFERENCES dbo.DimTerritories(TerritoryID_SK),
    CONSTRAINT FK_FactOrders_SOR_orders
        FOREIGN KEY (SOR_SK_orders)         REFERENCES dbo.Dim_SOR(SOR_SK),
    CONSTRAINT FK_FactOrders_SOR_orderdtls
        FOREIGN KEY (SOR_SK_orderdetails)   REFERENCES dbo.Dim_SOR(SOR_SK)
);
GO

CREATE TABLE dbo.FactOrders_Error (
    FactOrdersError_SK        INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    OrderID_NK                INT               NULL,
    ProductID_NK              INT               NULL,

    CustomerID_NK             NCHAR(5)          NULL,
    EmployeeID_NK             INT               NULL,
    ShipperID_NK              INT               NULL,
    TerritoryID_NK            NVARCHAR(20)      NULL,

    OrderDate                 DATETIME          NULL,
    RequiredDate              DATETIME          NULL,
    ShippedDate               DATETIME          NULL,

    UnitPrice                 DECIMAL(18,4)     NULL,
    Quantity                  SMALLINT          NULL,
    Discount                  REAL              NULL,
    Freight                   DECIMAL(18,4)     NULL,

    error_reason              NVARCHAR(255)     NULL,
    SOR_SK_orders             INT               NULL,
    SOR_SK_orderdetails       INT               NULL,
    staging_raw_id_orders     INT               NULL,
    staging_raw_id_orderdtls  INT               NULL,
    load_date                 DATETIME          NOT NULL DEFAULT GETDATE()
);
GO


INSERT INTO dbo.Dim_SOR (SOR_Name)
SELECT v.name
FROM (VALUES
    ('Categories'),
    ('Customers'),
    ('Employees'),
    ('OrderDetails'),
    ('Orders'),
    ('Products'),
    ('Region'),
    ('Shippers'),
    ('Suppliers'),
    ('Territories')
) AS v(name)
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.Dim_SOR s WHERE s.SOR_Name = v.name
);
GO