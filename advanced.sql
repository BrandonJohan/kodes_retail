USE kodes_retail;

DELIMITER $$

DROP TRIGGER IF EXISTS trg_UpdateInventory_AfterInsert$$

CREATE TRIGGER trg_UpdateInventory_AfterInsert
AFTER INSERT ON InvoiceDetail
FOR EACH ROW
BEGIN
    DECLARE v_InvoiceType   VARCHAR(10);
    DECLARE v_InvoiceStatus VARCHAR(10);

    SELECT InvoiceType, InvoiceStatus
    INTO v_InvoiceType, v_InvoiceStatus
    FROM Invoice
    WHERE InvoiceID = NEW.InvoiceID;

    IF v_InvoiceStatus = 'Completed' THEN

        IF v_InvoiceType = 'SALE' THEN
            UPDATE Product
            SET ProductQuantity = ProductQuantity - ABS(NEW.Quantity) 
            WHERE ProductCode = NEW.ProductCode
               AND ProductType = 'PRODUCT';                           

        ELSEIF v_InvoiceType = 'RETURN' THEN
            UPDATE Product
            SET ProductQuantity = ProductQuantity + ABS(NEW.Quantity)
            WHERE ProductCode = NEW.ProductCode
               AND ProductType = 'PRODUCT';
        END IF;

    END IF;
END$$

DROP TRIGGER IF EXISTS trg_RestoreInventory_AfterCancel$$

CREATE TRIGGER trg_RestoreInventory_AfterCancel
AFTER UPDATE ON Invoice
FOR EACH ROW
BEGIN
    IF OLD.InvoiceStatus = 'Completed' AND NEW.InvoiceStatus = 'Cancelled' THEN
        UPDATE Product p
        JOIN (
            SELECT ProductCode, SUM(ABS(Quantity)) AS TotalQty
            FROM InvoiceDetail
            WHERE InvoiceID = NEW.InvoiceID
            GROUP BY ProductCode
        ) d ON d.ProductCode = p.ProductCode
        SET p.ProductQuantity = p.ProductQuantity +
            IF(NEW.InvoiceType = 'SALE', d.TotalQty, -d.TotalQty)
        WHERE p.ProductType = 'PRODUCT';
    END IF;
END$$

DROP PROCEDURE IF EXISTS GetCustomerInvoiceHistory$$

CREATE PROCEDURE GetCustomerInvoiceHistory(IN p_CustomerID INT)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Customer WHERE CustomerID = p_CustomerID) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'CustomerID not found';
    END IF;

    SELECT
        i.InvoiceID,
        i.InvoiceDate,
        i.InvoiceType,
        i.InvoiceStatus,
        COUNT(d.InvoiceDetailID) AS TotalItems,
        ROUND(COALESCE(SUM(d.Quantity * d.UnitPrice), 0), 2) AS TotalValue
    FROM Invoice i
    LEFT JOIN InvoiceDetail d ON d.InvoiceID = i.InvoiceID
    WHERE i.CustomerID = p_CustomerID
    GROUP BY i.InvoiceID, i.InvoiceDate, i.InvoiceType, i.InvoiceStatus
    ORDER BY i.InvoiceDate DESC;
END$$

DELIMITER ;

CALL GetCustomerInvoiceHistory(12347);

START TRANSACTION;

SELECT ProductCode, ProductQuantity FROM Product WHERE ProductCode = '85123A';

INSERT INTO Invoice (InvoiceID, CustomerID, CountryID, InvoiceDate, InvoiceType)
VALUES ('TEST001', NULL, 1, NOW(), 'SALE');

INSERT INTO InvoiceDetail (InvoiceID, ProductCode, Quantity, UnitPrice)
VALUES ('TEST001', '85123A', 5, 2.550);

SELECT ProductCode, ProductQuantity FROM Product WHERE ProductCode = '85123A';

UPDATE Invoice
SET InvoiceStatus = 'Cancelled', CancelledAt = NOW(), CancelReason = 'Test cancel'
WHERE InvoiceID = 'TEST001';

SELECT ProductCode, ProductQuantity FROM Product WHERE ProductCode = '85123A';

ROLLBACK;
