USE kodes_retail;

-- Testing the Procedure (CustomerID exist)
CALL GetCustomerInvoiceHistory(12347);
-- Testing the Procedure (CustomerID doesn't exist)
CALL GetCustomerInvoiceHistory(00000);

ROLLBACK; -- Clear any leftover open transaction
-- Testing the Trigger
START TRANSACTION;

-- Before Transaction
SELECT ProductCode, ProductQuantity FROM Product WHERE ProductCode = '85123A';

-- Transaction
INSERT INTO Invoice (InvoiceID, CustomerID, CountryID, InvoiceDate, InvoiceType)
VALUES ('TEST001', NULL, 1, NOW(), 'SALE');

INSERT INTO InvoiceDetail (InvoiceID, ProductCode, Quantity, UnitPrice)
VALUES ('TEST001', '85123A', 5, 2.550);

-- After Transaction
SELECT ProductCode, ProductQuantity FROM Product WHERE ProductCode = '85123A';

-- Cancellation
UPDATE Invoice
SET InvoiceStatus = 'Cancelled', CancelledAt = NOW(), CancelReason = 'Test cancel'
WHERE InvoiceID = 'TEST001';

-- After Cancellation
SELECT ProductCode, ProductQuantity FROM Product WHERE ProductCode = '85123A';

-- Testing Negative Quantity
INSERT INTO Invoice (InvoiceID, CustomerID, CountryID, InvoiceDate, InvoiceType)
VALUES ('TEST002', NULL, 1, NOW(), 'SALE');

INSERT INTO InvoiceDetail (InvoiceID, ProductCode, Quantity, UnitPrice)
VALUES ('TEST002', '85123A', 10000, 2.550);

SELECT ProductCode, ProductQuantity FROM Product WHERE ProductCode = '85123A';

ROLLBACK;
