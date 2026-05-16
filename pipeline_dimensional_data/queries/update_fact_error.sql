USE ORDER_DDS;
GO

INSERT INTO dbo.FactOrders_Error (
    OrderID_NK,
    ProductID_NK,
    CustomerID_NK,
    EmployeeID_NK,
    ShipperID_NK,
    TerritoryID_NK,
    OrderDate,
    RequiredDate,
    ShippedDate,
    UnitPrice,
    Quantity,
    Discount,
    Freight,
    error_reason,
    SOR_SK_orders,
    SOR_SK_orderdetails,
    staging_raw_id_orders,
    staging_raw_id_orderdtls
)
SELECT
    o.OrderID,
    od.ProductID,
    o.CustomerID,
    o.EmployeeID,
    o.ShipVia,
    o.TerritoryID,
    o.OrderDate,
    o.RequiredDate,
    o.ShippedDate,
    od.UnitPrice,
    od.Quantity,
    od.Discount,
    o.Freight,
    CONCAT(
        CASE WHEN c.CustomerID_SK IS NULL THEN 'Missing/invalid CustomerID; ' ELSE '' END,
        CASE WHEN e.EmployeeID_SK IS NULL THEN 'Missing/invalid EmployeeID; ' ELSE '' END,
        CASE WHEN p.ProductID_SK IS NULL THEN 'Missing/invalid ProductID; ' ELSE '' END,
        CASE WHEN sh.ShipperID_SK IS NULL THEN 'Missing/invalid ShipperID; ' ELSE '' END,
        CASE WHEN t.TerritoryID_SK IS NULL THEN 'Missing/invalid TerritoryID; ' ELSE '' END
    ) AS error_reason,
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
  AND (
        c.CustomerID_SK IS NULL
     OR e.EmployeeID_SK IS NULL
     OR p.ProductID_SK IS NULL
     OR sh.ShipperID_SK IS NULL
     OR t.TerritoryID_SK IS NULL
  );
  