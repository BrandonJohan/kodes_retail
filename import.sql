USE kodes_retail;

DROP TABLE IF EXISTS staging_retail;

CREATE TABLE staging_retail (
    invoice_no     VARCHAR(10),
    stock_code     VARCHAR(20),
    description    VARCHAR(255),
    quantity       INT,
    invoice_date   DATETIME,
    unit_price     DECIMAL(10,3),
    customer_id    INT,
    country        VARCHAR(50),
    invoice_type   VARCHAR(10),
    product_type   VARCHAR(15),
    is_guest       BOOLEAN,
    customer_name  VARCHAR(100),
    customer_email VARCHAR(100),
    customer_phone VARCHAR(15)
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/formatted_transactions.csv'
INTO TABLE staging_retail
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' ESCAPED BY ''
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(invoice_no, stock_code, description, quantity, invoice_date, unit_price,
 customer_id, country, invoice_type, product_type, is_guest,
 customer_name, customer_email, customer_phone);

INSERT INTO Country (CountryName)
SELECT DISTINCT country
FROM staging_retail
ORDER BY country;

INSERT INTO Customer (CustomerID, CustomerName, CustomerPhone, CustomerEmail, IsGuest, CreatedAt)
SELECT customer_id,
       MAX(customer_name),
       MAX(customer_phone),
       MAX(customer_email),
       MAX(is_guest),
       MIN(invoice_date)
FROM staging_retail
GROUP BY customer_id;

SET SQL_SAFE_UPDATES = 0;

UPDATE Customer
SET CustomerPhone = 'Guest Number'
WHERE CustomerPhone = '';

SET SQL_SAFE_UPDATES = 1;

INSERT INTO Product (ProductCode, ProductDesc, ProductUnitPrice, ProductType)
SELECT stock_code,
       MAX(description),
       MAX(unit_price),
       MAX(product_type)
FROM staging_retail
GROUP BY stock_code;

INSERT INTO Invoice (InvoiceID, CustomerID, CountryID, InvoiceDate, InvoiceType)
SELECT s.invoice_no,
       MAX(s.customer_id),
       c.CountryID,
       MIN(s.invoice_date),
       MAX(s.invoice_type)
FROM staging_retail s
JOIN Country c ON c.CountryName = s.country
GROUP BY s.invoice_no, c.CountryID;

INSERT INTO InvoiceDetail (InvoiceID, ProductCode, Quantity, UnitPrice)
SELECT invoice_no, stock_code, quantity, unit_price
FROM staging_retail;

DROP TABLE staging_retail;

SELECT 'Country' AS tabel, COUNT(*) AS jumlah FROM Country
UNION ALL SELECT 'Customer',      COUNT(*) FROM Customer
UNION ALL SELECT 'Product',       COUNT(*) FROM Product
UNION ALL SELECT 'Invoice',       COUNT(*) FROM Invoice
UNION ALL SELECT 'InvoiceDetail', COUNT(*) FROM InvoiceDetail;
