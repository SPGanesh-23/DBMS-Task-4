CREATE DATABASE IF NOT EXISTS OrderManagementDB;
USE OrderManagementDB;

CREATE TABLE Customer (
    Customer_ID INT PRIMARY KEY,
    Customer_Name VARCHAR(100) NOT NULL,
    Email VARCHAR(100) NOT NULL UNIQUE,
    Phone VARCHAR(15) UNIQUE,
    City VARCHAR(50) NOT NULL
);

CREATE TABLE Category (
    Category_ID INT PRIMARY KEY,
    Category_Name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE Product (
    Product_ID INT PRIMARY KEY,
    Product_Name VARCHAR(100) NOT NULL,
    Category_ID INT NOT NULL,
    Price DECIMAL(10,2) NOT NULL,
    Stock INT NOT NULL,
    CONSTRAINT chk_product_price CHECK (Price > 0),
    CONSTRAINT chk_product_stock CHECK (Stock >= 0),
    CONSTRAINT fk_product_category
        FOREIGN KEY (Category_ID) REFERENCES Category(Category_ID)
);

CREATE TABLE Orders (
    Order_ID INT PRIMARY KEY,
    Customer_ID INT NOT NULL,
    Order_Date DATE NOT NULL,
    Total_Amount DECIMAL(10,2) NOT NULL DEFAULT 0,
    Order_Status VARCHAR(20) NOT NULL DEFAULT 'Pending',
    CONSTRAINT fk_order_customer
        FOREIGN KEY (Customer_ID) REFERENCES Customer(Customer_ID),
    CONSTRAINT chk_total_amount CHECK (Total_Amount >= 0),
    CONSTRAINT chk_order_status
        CHECK (Order_Status IN ('Pending', 'Shipped', 'Delivered', 'Cancelled'))
);

CREATE TABLE Order_Details (
    Order_Detail_ID INT PRIMARY KEY,
    Order_ID INT NOT NULL,
    Product_ID INT NOT NULL,
    Quantity INT NOT NULL,
    Price DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_detail_order
        FOREIGN KEY (Order_ID) REFERENCES Orders(Order_ID),
    CONSTRAINT fk_detail_product
        FOREIGN KEY (Product_ID) REFERENCES Product(Product_ID),
    CONSTRAINT chk_quantity CHECK (Quantity > 0),
    CONSTRAINT chk_order_price CHECK (Price > 0),
    CONSTRAINT uq_order_product UNIQUE (Order_ID, Product_ID)
);

INSERT INTO Customer
(Customer_ID, Customer_Name, Email, Phone, City)
VALUES
(1, 'Arun Kumar', 'arun@gmail.com', '9876543210', 'Chennai'),
(2, 'Priya Sharma', 'priya@gmail.com', '9876543211', 'Coimbatore'),
(3, 'Rahul Raj', 'rahul@gmail.com', '9876543212', 'Madurai'),
(4, 'Divya S', 'divya@gmail.com', '9876543213', 'Trichy'),
(5, 'Karthik R', 'karthik@gmail.com', '9876543214', 'Thoothukudi');

INSERT INTO Category
(Category_ID, Category_Name)
VALUES
(1, 'Electronics'),
(2, 'Accessories'),
(3, 'Home Appliances'),
(4, 'Stationery');

INSERT INTO Product
(Product_ID, Product_Name, Category_ID, Price, Stock)
VALUES
(101, 'Laptop', 1, 55000.00, 10),
(102, 'Smartphone', 1, 25000.00, 20),
(103, 'Headphones', 2, 2000.00, 30),
(104, 'Keyboard', 2, 1500.00, 25),
(105, 'Mouse', 2, 800.00, 40),
(106, 'Smart TV', 3, 35000.00, 8),
(107, 'Mixer Grinder', 3, 4500.00, 15),
(108, 'Notebook', 4, 100.00, 100),
(109, 'Pen Set', 4, 250.00, 80),
(110, 'Power Bank', 2, 1800.00, 35);

INSERT INTO Orders
(Order_ID, Customer_ID, Order_Date, Total_Amount, Order_Status)
VALUES
(1001, 1, '2026-10-01', 59000.00, 'Delivered'),
(1002, 2, '2026-10-03', 27300.00, 'Shipped'),
(1003, 1, '2026-10-05', 3800.00, 'Delivered'),
(1004, 3, '2026-10-08', 39500.00, 'Pending'),
(1005, 4, '2026-10-10', 2300.00, 'Delivered'),
(1006, 5, '2026-10-12', 5500.00, 'Shipped'),
(1007, 2, '2026-10-15', 3000.00, 'Pending'),
(1008, 1, '2026-10-18', 2050.00, 'Delivered');

INSERT INTO Order_Details
(Order_Detail_ID, Order_ID, Product_ID, Quantity, Price)
VALUES
(1, 1001, 101, 1, 55000.00),
(2, 1001, 103, 2, 2000.00),
(3, 1002, 102, 1, 25000.00),
(4, 1002, 104, 1, 1500.00),
(5, 1002, 105, 1, 800.00),
(6, 1003, 103, 1, 2000.00),
(7, 1003, 110, 1, 1800.00),
(8, 1004, 106, 1, 35000.00),
(9, 1004, 107, 1, 4500.00),
(10, 1005, 104, 1, 1500.00),
(11, 1005, 105, 1, 800.00),
(12, 1006, 107, 1, 4500.00),
(13, 1006, 108, 10, 100.00),
(14, 1007, 109, 4, 250.00),
(15, 1007, 103, 1, 2000.00),
(16, 1008, 105, 1, 800.00),
(17, 1008, 109, 5, 250.00);

SELECT * FROM Customer;
SELECT * FROM Category;
SELECT * FROM Product;
SELECT * FROM Orders;
SELECT * FROM Order_Details;

INSERT INTO Orders
(Order_ID, Customer_ID, Order_Date, Total_Amount, Order_Status)
VALUES
(1009, 3, '2026-10-20', 0, 'Pending');

INSERT INTO Order_Details
(Order_Detail_ID, Order_ID, Product_ID, Quantity, Price)
VALUES
(18, 1009, 103, 2, 2000.00),
(19, 1009, 105, 3, 800.00),
(20, 1009, 110, 1, 1800.00);

UPDATE Orders
SET Total_Amount = (
    SELECT SUM(Quantity * Price)
    FROM Order_Details
    WHERE Order_ID = 1009
)
WHERE Order_ID = 1009;

SELECT * FROM Orders
WHERE Order_ID = 1009;

UPDATE Orders
SET Order_Status = 'Shipped'
WHERE Order_ID = 1009;

SELECT
    o.Order_ID,
    c.Customer_ID,
    c.Customer_Name,
    c.Email,
    o.Order_Date,
    p.Product_ID,
    p.Product_Name,
    od.Quantity,
    od.Price AS Unit_Price,
    (od.Quantity * od.Price) AS Subtotal,
    o.Total_Amount,
    o.Order_Status
FROM Orders o
JOIN Customer c
    ON o.Customer_ID = c.Customer_ID
JOIN Order_Details od
    ON o.Order_ID = od.Order_ID
JOIN Product p
    ON od.Product_ID = p.Product_ID
ORDER BY o.Order_ID, od.Order_Detail_ID;

INSERT INTO Orders
(Order_ID, Customer_ID, Order_Date, Total_Amount, Order_Status)
VALUES
(1010, 4, '2026-10-22', 0, 'Pending');

INSERT INTO Order_Details
(Order_Detail_ID, Order_ID, Product_ID, Quantity, Price)
VALUES
(21, 1010, 108, 5, 100.00),
(22, 1010, 109, 2, 250.00);

UPDATE Orders
SET Total_Amount = (
    SELECT SUM(Quantity * Price)
    FROM Order_Details
    WHERE Order_ID = 1010
)
WHERE Order_ID = 1010;

UPDATE Orders
SET Order_Status = 'Shipped'
WHERE Order_ID = 1010;

UPDATE Orders
SET Order_Status = 'Delivered'
WHERE Order_ID = 1010;

UPDATE Order_Details
SET Quantity = 10
WHERE Order_ID = 1010
AND Product_ID = 108;

UPDATE Orders
SET Total_Amount = (
    SELECT SUM(Quantity * Price)
    FROM Order_Details
    WHERE Order_ID = 1010
)
WHERE Order_ID = 1010;

INSERT INTO Orders
(Order_ID, Customer_ID, Order_Date, Total_Amount, Order_Status)
VALUES
(1011, 5, '2026-10-23', 800.00, 'Cancelled');

INSERT INTO Order_Details
(Order_Detail_ID, Order_ID, Product_ID, Quantity, Price)
VALUES
(23, 1011, 105, 1, 800.00);

DELETE FROM Order_Details
WHERE Order_ID IN (
    SELECT Order_ID
    FROM Orders
    WHERE Order_Status = 'Cancelled'
);

DELETE FROM Orders
WHERE Order_Status = 'Cancelled';

SELECT
    o.Order_ID,
    c.Customer_Name,
    c.City,
    o.Order_Date,
    p.Product_Name,
    cat.Category_Name,
    od.Quantity,
    od.Price AS Unit_Price,
    (od.Quantity * od.Price) AS Subtotal,
    o.Total_Amount,
    o.Order_Status
FROM Orders o
JOIN Customer c
    ON o.Customer_ID = c.Customer_ID
JOIN Order_Details od
    ON o.Order_ID = od.Order_ID
JOIN Product p
    ON od.Product_ID = p.Product_ID
JOIN Category cat
    ON p.Category_ID = cat.Category_ID
ORDER BY o.Order_ID;

SELECT
    c.Customer_ID,
    c.Customer_Name,
    o.Order_ID,
    o.Order_Date,
    o.Total_Amount,
    o.Order_Status
FROM Customer c
JOIN Orders o
    ON c.Customer_ID = o.Customer_ID
ORDER BY c.Customer_ID, o.Order_Date;

SELECT
    c.Customer_Name,
    o.Order_ID,
    o.Order_Date,
    p.Product_Name,
    od.Quantity,
    od.Price,
    (od.Quantity * od.Price) AS Amount,
    o.Order_Status
FROM Customer c
JOIN Orders o
    ON c.Customer_ID = o.Customer_ID
JOIN Order_Details od
    ON o.Order_ID = od.Order_ID
JOIN Product p
    ON od.Product_ID = p.Product_ID
ORDER BY c.Customer_Name, o.Order_Date;

SELECT
    p.Product_ID,
    p.Product_Name,
    o.Order_ID,
    c.Customer_Name,
    od.Quantity,
    od.Price,
    (od.Quantity * od.Price) AS Subtotal
FROM Product p
JOIN Order_Details od
    ON p.Product_ID = od.Product_ID
JOIN Orders o
    ON od.Order_ID = o.Order_ID
JOIN Customer c
    ON o.Customer_ID = c.Customer_ID
ORDER BY p.Product_ID;

SELECT
    p.Product_ID,
    p.Product_Name,
    COUNT(od.Order_Detail_ID) AS Number_Of_Times_Ordered
FROM Product p
LEFT JOIN Order_Details od
    ON p.Product_ID = od.Product_ID
GROUP BY p.Product_ID, p.Product_Name
ORDER BY Number_Of_Times_Ordered DESC;

SELECT
    p.Product_ID,
    p.Product_Name,
    COALESCE(SUM(od.Quantity), 0) AS Total_Quantity_Sold
FROM Product p
LEFT JOIN Order_Details od
    ON p.Product_ID = od.Product_ID
GROUP BY p.Product_ID, p.Product_Name
ORDER BY Total_Quantity_Sold DESC;

SELECT
    c.Customer_ID,
    c.Customer_Name,
    COUNT(o.Order_ID) AS Number_Of_Orders
FROM Customer c
JOIN Orders o
    ON c.Customer_ID = o.Customer_ID
GROUP BY c.Customer_ID, c.Customer_Name
ORDER BY Number_Of_Orders DESC
LIMIT 1;

SELECT
    c.Customer_ID,
    c.Customer_Name,
    COUNT(o.Order_ID) AS Number_Of_Orders
FROM Customer c
JOIN Orders o
    ON c.Customer_ID = o.Customer_ID
GROUP BY c.Customer_ID, c.Customer_Name
HAVING COUNT(o.Order_ID) = (
    SELECT MAX(Order_Count)
    FROM (
        SELECT COUNT(*) AS Order_Count
        FROM Orders
        GROUP BY Customer_ID
    ) AS Counts
);

SELECT
    c.Customer_ID,
    c.Customer_Name,
    COALESCE(SUM(o.Total_Amount), 0) AS Total_Spending
FROM Customer c
LEFT JOIN Orders o
    ON c.Customer_ID = o.Customer_ID
GROUP BY c.Customer_ID, c.Customer_Name
ORDER BY Total_Spending DESC;

SELECT
    ROUND(AVG(Total_Amount), 2) AS Average_Order_Value
FROM Orders;

SELECT
    c.Customer_ID,
    c.Customer_Name,
    ROUND(AVG(o.Total_Amount), 2) AS Average_Order_Value
FROM Customer c
JOIN Orders o
    ON c.Customer_ID = o.Customer_ID
GROUP BY c.Customer_ID, c.Customer_Name
ORDER BY Average_Order_Value DESC;

SELECT
    SUM(Total_Amount) AS Total_Sales_Amount
FROM Orders
WHERE Order_Status <> 'Cancelled';

SELECT
    p.Product_ID,
    p.Product_Name,
    SUM(od.Quantity) AS Total_Quantity,
    SUM(od.Quantity * od.Price) AS Product_Sales
FROM Product p
JOIN Order_Details od
    ON p.Product_ID = od.Product_ID
JOIN Orders o
    ON od.Order_ID = o.Order_ID
WHERE o.Order_Status <> 'Cancelled'
GROUP BY p.Product_ID, p.Product_Name
ORDER BY Product_Sales DESC;

SELECT
    c.Customer_ID,
    c.Customer_Name,
    COUNT(o.Order_ID) AS Total_Orders,
    SUM(o.Total_Amount) AS Total_Spending
FROM Customer c
JOIN Orders o
    ON c.Customer_ID = o.Customer_ID
WHERE o.Order_Status <> 'Cancelled'
GROUP BY c.Customer_ID, c.Customer_Name
ORDER BY Total_Spending DESC;

SELECT
    Order_Status,
    COUNT(*) AS Number_Of_Orders,
    SUM(Total_Amount) AS Total_Amount
FROM Orders
GROUP BY Order_Status;

SELECT
    p.Product_ID,
    p.Product_Name,
    COUNT(od.Order_Detail_ID) AS Times_Ordered,
    SUM(od.Quantity) AS Quantity_Sold,
    SUM(od.Quantity * od.Price) AS Sales_Amount
FROM Product p
JOIN Order_Details od
    ON p.Product_ID = od.Product_ID
JOIN Orders o
    ON od.Order_ID = o.Order_ID
WHERE o.Order_Status <> 'Cancelled'
GROUP BY p.Product_ID, p.Product_Name
ORDER BY Sales_Amount DESC;

SELECT
    c.Customer_ID,
    c.Customer_Name,
    COUNT(o.Order_ID) AS Total_Orders,
    SUM(o.Total_Amount) AS Total_Spending,
    ROUND(AVG(o.Total_Amount), 2) AS Average_Order_Value,
    MAX(o.Total_Amount) AS Highest_Order_Value
FROM Customer c
JOIN Orders o
    ON c.Customer_ID = o.Customer_ID
WHERE o.Order_Status <> 'Cancelled'
GROUP BY c.Customer_ID, c.Customer_Name
ORDER BY Total_Spending DESC;

SELECT * FROM Customer;
SELECT * FROM Category;
SELECT * FROM Product;
SELECT * FROM Orders;
SELECT * FROM Order_Details;

SHOW TABLES;

DESC Customer;
DESC Category;
DESC Product;
DESC Orders;
DESC Order_Details;