USE ORDER_DDS;

INSERT INTO dbo.FactOrders (
    OrderID_NK,
    ProductID_NK,
    CustomerID_SK,
    EmployeeID_SK,
    ProductID_SK,
    ShipperID_SK,
    TerritoryID_SK,
    OrderDate,
    RequiredDate,
    ShippedDate,
    UnitPrice,
    Quantity,
    Discount,
    Freight,
    SOR_SK_orders,
    SOR_SK_orderdetails,
    staging_raw_id_orders,
    staging_raw_id_orderdtls
)
SELECT
    o.OrderID,
    od.ProductID,
    c.CustomerID_SK,
    e.EmployeeID_SK,
    p.ProductID_SK,
    sh.ShipperID_SK,
    t.TerritoryID_SK,
    o.OrderDate,
    o.RequiredDate,
    o.ShippedDate,
    od.UnitPrice,
    od.Quantity,
    od.Discount,
    o.Freight,
    sor_o.SOR_SK,
    sor_od.SOR_SK,
    o.staging_raw_id_sk,
    od.staging_raw_id_sk
FROM dbo.staging_orders o
INNER JOIN dbo.staging_order_details od
    ON o.OrderID = od.OrderID
INNER JOIN dbo.Dim_SOR sor_o
    ON sor_o.SOR_Name = 'Orders'
INNER JOIN dbo.Dim_SOR sor_od
    ON sor_od.SOR_Name = 'OrderDetails'
LEFT JOIN dbo.DimCustomers c
    ON c.CustomerID_NK = o.CustomerID
   AND c.is_current = 1
LEFT JOIN dbo.DimEmployees e
    ON e.EmployeeID_NK = o.EmployeeID
   AND e.is_deleted = 0
LEFT JOIN dbo.DimProducts p
    ON p.ProductID_NK = od.ProductID
   AND p.is_current = 1
   AND p.is_deleted = 0
LEFT JOIN dbo.DimShippers sh
    ON sh.ShipperID_NK = o.ShipVia
   AND sh.is_deleted = 0
LEFT JOIN dbo.DimTerritories t
    ON t.TerritoryID_NK = o.TerritoryID
WHERE o.OrderDate >= '{start_date}'
  AND o.OrderDate < '{end_date}'
  AND c.CustomerID_SK IS NOT NULL
  AND e.EmployeeID_SK IS NOT NULL
  AND p.ProductID_SK IS NOT NULL
  AND sh.ShipperID_SK IS NOT NULL
  AND t.TerritoryID_SK IS NOT NULL;