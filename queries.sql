USE kodes_retail;

-- Query 1
SET SQL_SAFE_UPDATES = 0;

UPDATE Product
SET ProductUnitPrice = ProductUnitPrice * 1.08
WHERE ProductUnitPrice < 5.00
   AND ProductUnitPrice > 0
   AND ProductType = 'PRODUCT';

SET SQL_SAFE_UPDATES = 1;

-- Query 2 
UPDATE Invoice
SET InvoiceStatus = 'Cancelled'
WHERE InvoiceID = '000000' -- Replace with the InvoiceNo the customer asked to cancel
   AND InvoiceType = 'SALE'
   AND InvoiceStatus = 'Completed';

SELECT ROW_COUNT() AS RowsCancelled; -- Report changes

-- Query 3
SELECT
   c.CountryName, 
   ROUND(SUM(d.Quantity * d.UnitPrice), 2) AS TotalRevenue, -- Revenue = quantity * unitprice
   COUNT(DISTINCT i.InvoiceID) AS TotalCompletedInvoices
FROM Invoice i
JOIN Country c ON c.CountryID = i.CountryID
JOIN InvoiceDetail d ON d.InvoiceID = i.InvoiceID
WHERE i.InvoiceStatus = 'Completed' AND i.InvoiceType = 'SALE'
GROUP BY c.CountryID, c.CountryName
ORDER BY TotalRevenue DESC;

-- Query 4
WITH CustomerSpend AS (
   SELECT
      cu.CustomerID, 
      cu.CustomerName, 
      cu.CustomerPhone, 
      cu.CustomerEmail, 
      SUM(d.Quantity * d.UnitPrice) AS TotalSpend
   FROM Customer cu
   JOIN Invoice i ON i.CustomerID = cu.CustomerID
   JOIN InvoiceDetail d ON d.InvoiceID = i.InvoiceID
   WHERE i.InvoiceStatus = 'Completed' AND i.InvoiceType = 'SALE'
   GROUP BY cu.CustomerID, cu.CustomerName, cu.CustomerPhone, cu.CustomerEmail
)

SELECT 
   CustomerID, 
   CustomerName, 
   CustomerPhone, 
   CustomerEmail, 
   ROUND(TotalSpend, 2) AS TotalSpend
FROM CustomerSpend
WHERE TotalSpend > (SELECT AVG(TotalSpend) FROM CustomerSpend) -- nested subquery
ORDER BY TotalSpend DESC;


-- Query 5
SELECT 
   p.ProductCode, 
   p.ProductDesc
FROM Product p
WHERE NOT EXISTS(
   SELECT 1
   FROM InvoiceDetail d
   JOIN Invoice i ON i.InvoiceID = d.InvoiceID
   JOIN Country c ON c.CountryID = i.CountryID
   WHERE d.ProductCode   = p.ProductCode
      AND c.CountryName   = 'Germany'
      AND i.InvoiceStatus = 'Completed'
      AND i.InvoiceType   = 'SALE'
)
AND (                                  -- sold in at least 2 other countries
   SELECT COUNT(DISTINCT i.CountryID)
   FROM InvoiceDetail d
   JOIN Invoice i ON i.InvoiceID = d.InvoiceID
   JOIN Country c ON c.CountryID = i.CountryID
   WHERE d.ProductCode   = p.ProductCode
      AND c.CountryName  <> 'Germany'
      AND i.InvoiceStatus = 'Completed'
      AND i.InvoiceType   = 'SALE'
) >= 2
ORDER BY p.ProductCode;
