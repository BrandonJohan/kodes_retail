DROP DATABASE IF EXISTS kodes_retail;
CREATE DATABASE kodes_retail;
USE kodes_retail;

CREATE TABLE Country (
    CountryID INT AUTO_INCREMENT PRIMARY KEY,
    CountryName VARCHAR(50) NOT NULL UNIQUE
);


CREATE TABLE Customer (
    CustomerID INT PRIMARY KEY,
    CustomerName VARCHAR(100) NOT NULL DEFAULT 'John Doe',
    CustomerPhone VARCHAR(15) NOT NULL DEFAULT 'Guest Number',
    CustomerEmail VARCHAR(100) NOT NULL DEFAULT 'john.doe@gmail.com',
    IsGuest BOOLEAN NOT NULL DEFAULT FALSE, 
    CreatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Product (
    ProductCode VARCHAR(20) PRIMARY KEY,
    ProductDesc VARCHAR(255) NOT NULL,
    ProductUnitPrice DECIMAL(10,3) NOT NULL DEFAULT 0,
    ProductQuantity INT NOT NULL DEFAULT 0,
    ProductType VARCHAR(15) NOT NULL DEFAULT 'PRODUCT',

    CONSTRAINT chk_product_price CHECK (ProductUnitPrice >= 0),
    CONSTRAINT chk_product_type CHECK (ProductType IN ('PRODUCT', 'NON_PRODUCT'))
);

CREATE TABLE Invoice (
    InvoiceID   VARCHAR(10) PRIMARY KEY,
    CustomerID  INT NULL,
    CountryID   INT NOT NULL,
    InvoiceDate DATETIME NOT NULL,
    InvoiceType VARCHAR(10) NOT NULL DEFAULT 'SALE',
    InvoiceStatus VARCHAR(10) NOT NULL DEFAULT 'Completed',
    CancelledAt DATETIME NULL, 
    CancelReason VARCHAR(255) NULL, 
    
    CONSTRAINT chk_invoice_type CHECK (InvoiceType IN('SALE', 'RETURN')),
    CONSTRAINT chk_invoice_status  CHECK (InvoiceStatus IN('Completed', 'Cancelled')),
    CONSTRAINT fk_invoice_customer FOREIGN KEY (CustomerID)
        REFERENCES Customer (CustomerID)
        ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT fk_invoice_country FOREIGN KEY (CountryID)
        REFERENCES Country (CountryID)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE InvoiceDetail (
    InvoiceDetailID INT AUTO_INCREMENT PRIMARY KEY,
    InvoiceID VARCHAR(10) NOT NULL,
    ProductCode VARCHAR(20) NOT NULL,
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(10,3) NOT NULL,


    CONSTRAINT chk_quantity CHECK (Quantity != 0),
    CONSTRAINT chk_unit_price CHECK (UnitPrice >= 0),
    CONSTRAINT fk_detail_invoice FOREIGN KEY (InvoiceID)
        REFERENCES Invoice (InvoiceID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_detail_product FOREIGN KEY (ProductCode)
        REFERENCES Product (ProductCode)
        ON DELETE RESTRICT ON UPDATE CASCADE
);
