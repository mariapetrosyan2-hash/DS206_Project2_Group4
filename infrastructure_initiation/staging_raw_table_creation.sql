USE ORDER_DDS;
GO

-- =========================
-- Categories
-- =========================
CREATE TABLE staging_categories (
    staging_raw_id_sk INT IDENTITY(1,1) PRIMARY KEY,
    CategoryID INT,
    CategoryName VARCHAR(255),
    Description VARCHAR(500)
);

-- =========================
-- Customers
-- =========================
CREATE TABLE staging_customers (
    staging_raw_id_sk INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID VARCHAR(10),
    CompanyName VARCHAR(255),
    ContactName VARCHAR(255),
    ContactTitle VARCHAR(100),
    Address VARCHAR(255),
    City VARCHAR(100),
    Region VARCHAR(100),
    PostalCode VARCHAR(20),
    Country VARCHAR(100),
    Phone VARCHAR(50),
    Fax VARCHAR(50)
);

-- =========================
-- Employees
-- =========================
CREATE TABLE staging_employees (
    staging_raw_id_sk INT IDENTITY(1,1) PRIMARY KEY,
    EmployeeID INT,
    LastName VARCHAR(100),
    FirstName VARCHAR(100),
    Title VARCHAR(100),
    TitleOfCourtesy VARCHAR(50),
    BirthDate DATE,
    HireDate DATE,
    Address VARCHAR(255),
    City VARCHAR(100),
    Region VARCHAR(100),
    PostalCode VARCHAR(20),
    Country VARCHAR(100),
    HomePhone VARCHAR(50),
    Extension VARCHAR(10),
    Notes VARCHAR(MAX),
    ReportsTo INT,
    PhotoPath VARCHAR(255)
);

-- =========================
-- Orders
-- =========================
CREATE TABLE staging_orders (
    staging_raw_id_sk INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT,
    CustomerID VARCHAR(10),
    EmployeeID INT,
    OrderDate DATE,
    RequiredDate DATE,
    ShippedDate DATE,
    ShipVia INT,
    Freight DECIMAL(10,2),
    ShipName VARCHAR(255),
    ShipAddress VARCHAR(255),
    ShipCity VARCHAR(100),
    ShipRegion VARCHAR(100),
    ShipPostalCode VARCHAR(20),
    ShipCountry VARCHAR(100),
    TerritoryID VARCHAR(50)
);

-- =========================
-- Order Details
-- =========================
CREATE TABLE staging_order_details (
    staging_raw_id_sk INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT,
    ProductID INT,
    UnitPrice DECIMAL(10,2),
    Quantity INT,
    Discount DECIMAL(5,2)
);

-- =========================
-- Products
-- =========================
CREATE TABLE staging_products (
    staging_raw_id_sk INT IDENTITY(1,1) PRIMARY KEY,
    ProductID INT,
    ProductName VARCHAR(255),
    SupplierID INT,
    CategoryID INT,
    QuantityPerUnit VARCHAR(100),
    UnitPrice DECIMAL(10,2),
    UnitsInStock INT,
    UnitsOnOrder INT,
    ReorderLevel INT,
    Discontinued INT
);

-- =========================
-- Region
-- =========================
CREATE TABLE staging_region (
    staging_raw_id_sk INT IDENTITY(1,1) PRIMARY KEY,
    RegionID INT,
    RegionDescription VARCHAR(255),
    RegionCategory VARCHAR(50),
    RegionImportance VARCHAR(20)
);

-- =========================
-- Shippers
-- =========================
CREATE TABLE staging_shippers (
    staging_raw_id_sk INT IDENTITY(1,1) PRIMARY KEY,
    ShipperID INT,
    CompanyName VARCHAR(255),
    Phone VARCHAR(50)
);

-- =========================
-- Suppliers
-- =========================
CREATE TABLE staging_suppliers (
    staging_raw_id_sk INT IDENTITY(1,1) PRIMARY KEY,
    SupplierID INT,
    CompanyName VARCHAR(255),
    ContactName VARCHAR(255),
    ContactTitle VARCHAR(100),
    Address VARCHAR(255),
    City VARCHAR(100),
    Region VARCHAR(100),
    PostalCode VARCHAR(20),
    Country VARCHAR(100),
    Phone VARCHAR(50),
    Fax VARCHAR(50),
    HomePage VARCHAR(MAX)
);

-- =========================
-- Territories
-- =========================
CREATE TABLE staging_territories (
    staging_raw_id_sk INT IDENTITY(1,1) PRIMARY KEY,
    TerritoryID VARCHAR(50),
    TerritoryDescription VARCHAR(255),
    TerritoryCode VARCHAR(50),
    RegionID INT
);