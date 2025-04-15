Create database online_sales;
use online_sales;

SHOW VARIABLES LIKE "local_infile";
SET GLOBAL local_infile = 1;

CREATE TABLE online_sales (
    InvoiceNo VARCHAR(50),
    StockCode VARCHAR(50),
    Description TEXT,
    Quantity INT,
    InvoiceDate TEXT, -- we'll convert later
    UnitPrice DECIMAL(10,2),
    CustomerID INT,
    Country VARCHAR(100),
    Discount DECIMAL(10,2),
    PaymentMethod VARCHAR(50),
    ShippingCost DECIMAL(10,2),
    Category VARCHAR(100),
    SalesChannel VARCHAR(50),
    ReturnStatus VARCHAR(20),
    ShipmentProvider VARCHAR(50),
    WarehouseLocation VARCHAR(100),
    OrderPriority VARCHAR(20)
);


LOAD DATA LOCAL INFILE 'C:\Users\SASHAOO7\Downloads\Online Sales Dataset -SQL'
INTO TABLE online_sales
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT * FROM online_sales.online_sales;
Select Count(*) from online_sales;
DESCRIBE online_sales;

-- Step 1: Add a new column of DATE type
ALTER TABLE online_sales
ADD COLUMN InvoiceDate_Formatted DATE;

-- Step 2: Update new column by converting existing text to DATE
UPDATE online_sales
SET InvoiceDate_Formatted = STR_TO_DATE(InvoiceDate, '%d-%m-%Y');  -- or use correct format

SELECT 
  InvoiceDate_Formatted,
  YEAR(InvoiceDate_Formatted) AS year,
  MONTH(InvoiceDate_Formatted) AS month
FROM online_sales
LIMIT 10;

-- 🔹 BASIC SELECT & FILTERING

-- 1. List the first 10 records from the table.
SELECT * FROM online_sales LIMIT 10;

-- 2. Show all distinct countries from where customers placed orders.
SELECT DISTINCT Country FROM online_sales;

-- 3. Retrieve all orders where the Quantity is greater than 10.
SELECT * FROM online_sales WHERE Quantity > 10;

-- 4. Get all rows where the PaymentMethod is 'Credit Card' and Country is 'United Kingdom'.
SELECT * FROM online_sales WHERE PaymentMethod = 'Credit Card' AND Country = 'United Kingdom';

-- 🔹 AGGREGATION & GROUP BY

-- 5. Find the total number of orders made.
SELECT COUNT(DISTINCT InvoiceNo) AS total_orders FROM online_sales;

-- 6. Calculate the total revenue generated (Quantity × UnitPrice) for each country.
SELECT Country, SUM(Quantity * UnitPrice) AS total_revenue FROM online_sales GROUP BY Country;

-- 7. Show the average discount offered for each PaymentMethod.
SELECT PaymentMethod, AVG(Discount) AS avg_discount FROM online_sales GROUP BY PaymentMethod;

-- 8. List top 5 countries with the highest total shipping cost.
SELECT Country, SUM(ShippingCost) AS total_shipping FROM online_sales 
GROUP BY Country 
ORDER BY total_shipping DESC 
LIMIT 5;

-- 9. Get the total quantity sold per category.
SELECT Category, SUM(Quantity) AS total_quantity_sold FROM online_sales GROUP BY Category;

-- 🔹 DATE-RELATED QUERIES

-- 10. Show the number of orders placed per month.
SELECT 
    EXTRACT(YEAR FROM InvoiceDate_Formatted) AS year, 
    EXTRACT(MONTH FROM InvoiceDate_Formatted) AS month, 
    COUNT(DISTINCT InvoiceNo) AS order_count
FROM online_sales
GROUP BY year, month
ORDER BY year, month;

-- 11. List the top 3 invoice dates with the highest revenue.
SELECT InvoiceDate_Formatted, SUM(Quantity * UnitPrice) AS total_revenue
FROM online_sales
GROUP BY InvoiceDate_Formatted
ORDER BY total_revenue DESC
LIMIT 3;

-- 12. Count how many orders were placed in 2022.
SELECT COUNT(DISTINCT InvoiceNo) AS total_orders_2022 
FROM online_sales 
WHERE YEAR(InvoiceDate_Formatted) = 2022;

-- 🔹 JOINS & ADVANCED FILTERS

-- 13. Find all orders where the CustomerID is missing (NULL).
SELECT * FROM online_sales WHERE CustomerID IS NULL;

-- 14. Show all orders with a discount greater than 20% of the unit price.
SELECT * FROM online_sales WHERE Discount > (0.2 * UnitPrice);

-- 🔹 ORDERING & LIMITING RESULTS

-- 15. List the top 10 most expensive products by UnitPrice.
SELECT Description, UnitPrice FROM online_sales 
ORDER BY UnitPrice DESC 
LIMIT 10;

-- 16. Show the top 5 ShipmentProviders with the highest shipping costs.
SELECT ShipmentProvider, SUM(ShippingCost) AS total_shipping
FROM online_sales
GROUP BY ShipmentProvider
ORDER BY total_shipping DESC
LIMIT 5;

-- 🔹 BUSINESS-RELATED ANALYSIS

-- 17. Which sales channel (Online/Offline) generates the most revenue?
SELECT SalesChannel, SUM(Quantity * UnitPrice) AS total_revenue
FROM online_sales
GROUP BY SalesChannel
ORDER BY total_revenue DESC;

-- 18. What is the most frequently returned category (based on ReturnStatus)?
SELECT Category, COUNT(*) AS return_count
FROM online_sales
WHERE ReturnStatus = 'Returned'
GROUP BY Category
ORDER BY return_count DESC
LIMIT 1;

-- 19. Identify the WarehouseLocation handling the most orders.
SELECT WarehouseLocation, COUNT(*) AS order_count
FROM online_sales
GROUP BY WarehouseLocation
ORDER BY order_count DESC
LIMIT 1;

-- 20. Find which OrderPriority level contributes the most revenue.
SELECT OrderPriority, SUM(Quantity * UnitPrice) AS total_revenue
FROM online_sales
GROUP BY OrderPriority
ORDER BY total_revenue DESC
LIMIT 1;
