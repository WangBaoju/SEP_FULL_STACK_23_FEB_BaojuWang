--Assignment3 Written By ---- Baoju Wang -------  02/16/2023

USE Northwind
GO

--1. List all cities that have both Employees and Customers.
--a. use join
SELECT DISTINCT c.City
FROM Customers c JOIN Employees e ON c.City = e.City

--b. use subquery
SELECT DISTINCT City
FROM Customers
WHERE City IN (
    SELECT DISTINCT City
    FROM Employees
)

--2. List all cities that have Customers but no Employee.
--a. Use sub-query
SELECT DISTINCT City
FROM Customers
WHERE City NOT IN (
    SELECT DISTINCT City
    FROM Employees
)

--b.Do not use sub-query
SELECT DISTINCT c.City
FROM Customers c LEFT JOIN Employees e ON c.City = e.City
WHERE e.City IS NULL

--3. List all products and their total order quantities throughout all orders.
SELECT p.ProductName, SUM(od.Quantity) AS ProductQuantity
FROM Orders o JOIN [Order Details] od ON o.OrderID = od.OrderID JOIN Products p ON p.ProductID = od.ProductID
GROUP BY p.ProductName
ORDER BY p.ProductName

--4. List all Customer Cities and total products ordered by that city.
SELECT c.City, SUM(od.Quantity) AS ProductsQuantity
FROM [Order Details] od JOIN Orders o ON o.OrderID = od.OrderID
JOIN Customers c ON c.CustomerID = o.CustomerID
GROUP BY c.City
ORDER BY c.City


--5. List all Customer Cities that have at least two customers.
--a.      Use union
SELECT City
FROM Customers
GROUP BY City
HAVING COUNT(*) >= 2
UNION
SELECT City
FROM Suppliers
GROUP BY City
HAVING COUNT(*) >= 2

--b.      Use sub-query and no union
SELECT*
FROM (
    SELECT City, COUNT(CustomerID) AS NumOfCustomers
    FROM Customers
    GROUP BY City 
)dt
WHERE dt.NumOfCustomers >= 2
ORDER BY dt.NumOfCustomers DESC

--6. List all Customer Cities that have ordered at least two different kinds of products.
SELECT dt.City AS CustomerCity, dt.CountedProduct
FROM (
    SELECT c.City, COUNT(p.ProductID) AS CountedProduct
    FROM Customers c JOIN Orders o ON c.CustomerID = o.CustomerID JOIN [Order Details] od ON o.OrderID = od.OrderID
    JOIN Products p ON p.ProductID = od.ProductID
    GROUP BY c.City
)dt
WHERE dt.CountedProduct >= 2
ORDER BY CustomerCity


--7. List all Customers who have ordered products, but have the ‘ship city’ on the
-- order different from their own customer cities.
SELECT DISTINCT c.ContactName
FROM Customers c JOIN Orders o on c.CustomerID = o.CustomerID
WHERE c.City NOT IN (
    SELECT DISTINCT o.ShipCity
    FROM Customers c2 JOIN Orders o ON c2.CustomerID = o.CustomerID
    WHERE c.ContactName = c2.ContactName
)
--8. List 5 most popular products, their average price, and the customer city that ordered most quantity of it.


SELECT dt.ProductName, dt.AveragePrice
FROM (
    SELECT p.ProductName, AVG(p.UnitPrice) AS AveragePrice, COUNT(o.OrderID) AS CountedOrder, RANK()OVER(ORDER BY COUNT(o.OrderID) DESC) RNK
    FROM Customers c JOIN Orders o ON c.CustomerID = o.CustomerID JOIN [Order Details] od ON o.OrderID = od.OrderID
    JOIN Products p ON p.ProductID = od.ProductID
    GROUP BY p.ProductName
)dt
WHERE RNK <= 5
 
--9. List all cities that have never ordered something but we have employees there.

--a.Use sub-query
SELECT DISTINCT City
FROM Employees
WHERE City NOT IN (
    SELECT DISTINCT ShipCity
    FROM Orders
)

--b.Do not use sub-query
SELECT DISTINCT City
FROM Employees e LEFT JOIN Orders o ON e.City = o.ShipCity 
WHERE ShipCity IS NULL

--10. List one city, if exists, that is the city from where the employee sold most orders 
--(not the product quantity) is, and also the city of most total quantity of products ordered from. 
--(tip: join  sub-query)
SELECT dt.City1, dt2.City2
FROM (
    SELECT c.City AS City1, COUNT(o.OrderID) AS NumOfOrders, RANK() OVER (ORDER BY COUNT(o.OrderID) DESC) RNK
    FROM Customers c JOIN Orders o ON c.CustomerID = o.CustomerID
    GROUP BY c.City
)dt 
JOIN (
    SELECT c.City AS City2, SUM(od.Quantity) AS QuantityOfOrders, RANK() OVER (ORDER BY SUM(od.Quantity) DESC) RNK
    FROM Customers c JOIN Orders o ON c.CustomerID = o.CustomerID JOIN [Order Details] od ON od.OrderID = o.OrderID
    GROUP BY c.City
) dt2 ON dt.City1 = dt2.City2
WHERE dt.RNK = 1 AND dt2.RNK = 1

--11. How do you remove the duplicates record of a table?
--We can remove the duplicates using the DELETE keyword and subquery.
-- The subquery to define a unique record.
-- Using the Order Details table as an exmple
DELETE FROM [Order Details]
WHERE OrderID NOT IN (
    SELECT MIN(OrderID)
    FROM [Order Details]
    GROUP BY OrderID, ProductID, UnitPrice, Quantity, Discount
)