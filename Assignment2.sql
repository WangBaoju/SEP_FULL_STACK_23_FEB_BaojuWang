--Assignment2 Written by Baoju Wang Feb15, 2023

--1. How many products can you find in the Production.Product table?
SELECT COUNT(ProductID)
FROM Production.Product

--2. Write a query that retrieves the number of products in the Production.Product table
-- that are included in a subcategory. The rows that have NULL in column ProductSubcategoryID 
-- are considered to not be a part of any subcategory.
SELECT COUNT(ProductID)
FROM Production.Product
WHERE ProductSubcategoryID IS NOT NULL

--3. How many Products reside in each SubCategory? Write a query to display the results with the following titles.
-- ProductSubcategoryID CountedProducts

--with the NULL ProductSubcategoryID included
SELECT ProductSubcategoryID, COUNT(ProductID) AS CountedProducts
FROM Production.Product
GROUP BY ProductSubcategoryID

--or without the  NULL ProductSubcategoryID
SELECT ProductSubcategoryID, COUNT(ProductID) AS CountedProducts
FROM Production.Product
WHERE ProductSubcategoryID IS NOT NULL
GROUP BY ProductSubcategoryID

--4. How many products that do not have a product subcategory.
SELECT COUNT(ProductID) AS CountedProducts
FROM Production.Product
WHERE ProductSubcategoryID IS NULL

--5. Write a query to list the sum of products quantity in the Production.ProductInventory table.
SELECT ProductID, SUM(Quantity)
FROM Production.ProductInventory
GROUP BY ProductID

--6. Write a query to list the sum of products in the Production.ProductInventory table 
-- and LocationID set to 40 and limit the result to include just summarized quantities less than 100.

SELECT dt.ProductID,  dt.TheSum
FROM (
    SELECT ProductID, SUM(Quantity) AS TheSum
    FROM Production.ProductInventory
    WHERE LocationID = 40
    GROUP BY ProductID
) dt
WHERE dt.TheSum < 100
ORDER BY dt.ProductID

--7. Write a query to list the sum of products with the shelf information in the Production.ProductInventory table 
-- and LocationID set to 40 and limit the result to include just summarized quantities less than 100

SELECT dt. Shelf, dt.ProductID,  dt.TheSum
FROM (
    SELECT Shelf, ProductID, SUM(Quantity) AS TheSum
    FROM Production.ProductInventory
    WHERE LocationID = 40
    GROUP BY Shelf, ProductID
) dt
WHERE dt.TheSum < 100
ORDER BY dt.Shelf, dt.ProductID

--8. Write the query to list the average quantity for products where column LocationID has the value of 10 
-- from the table Production.ProductInventory table.
SELECT ProductID, AVG(Quantity) AS TheAvg
FROM Production.ProductInventory
WHERE LocationID = 10
GROUP BY ProductID

--9. Write query  to see the average quantity  of  products by shelf  from the table Production.ProductInventory

SELECT ProductID, Shelf, AVG(Quantity) AS TheAvg
FROM Production.ProductInventory
GROUP BY ProductID, Shelf
ORDER BY ProductID

--10. Write query  to see the average quantity  of  products by shelf excluding rows that has the value of N/A 
--in the column Shelf from the table Production.ProductInventory

SELECT ProductID, Shelf, AVG(Quantity) AS TheAvg
FROM Production.ProductInventory
GROUP BY ProductID, Shelf
WHERE Shelf IS NOT NULL
ORDER BY ProductID

--11. List the members (rows) and average list price in the Production.Product table. 
--This should be grouped independently over the Color and the Class column. 
--Exclude the rows where Color or Class are null.
SELECT Class, Color, COUNT(ProductID) AS TheCount, AVG(ListPrice) AS AvgPrice
FROM Production.Product
WHERE Class IS NOT NULL AND Color IS NOT NULL
GROUP BY Class, Color
ORDER BY Class, Color

--12. Write a query that lists the country and province names from person. CountryRegion and 
--person. StateProvince tables. Join them and produce a result set similar to the following.

SELECT pc.Name AS Country, ps.Name AS Province 
FROM Person.CountryRegion pc JOIN Person.StateProvince ps ON pc.CountryRegionCode = ps.CountryRegionCode

--13. Write a query that lists the country and province names from person.CountryRegion 
--and person. StateProvince tables and list the countries filter them by Germany and Canada. 
--Join them and produce a result set similar to the following.

SELECT pc.Name AS Country, ps.Name AS Province 
FROM Person.CountryRegion pc JOIN Person.StateProvince ps ON pc.CountryRegionCode = ps.CountryRegionCode
WHERE pc.Name IN ('Germany', 'Canada')
ORDER BY Country, Province


--USE NorthWind
--14. List all Products that has been sold at least once in last 25 years. 
-- how to filter the orderdate into the range of last 25 years?
DECLARE @date1 DATE
SET @date1 = '1998-02-15'
SELECT DISTINCT p.ProductName
FROM dbo.Orders o JOIN dbo.[Order Details] od ON o.OrderID = od.OrderID JOIN dbo.Products p ON od.ProductID = p.ProductID
WHERE o.OrderDate > @date1
ORDER BY p.ProductName

--15. List top 5 locations (Zip Code) where the products sold most.
SELECT TOP 5 o.ShipPostalCode, COUNT(o.OrderID) AS CountedOrder
FROM dbo.[Order Details] od JOIN dbo.Orders o ON od.OrderID = o.OrderID JOIN dbo.Products p ON p.ProductID = od.ProductID
GROUP BY o.ShipPostalCode
ORDER BY CountedOrder DESC

--16.List top 5 locations (Zip Code) where the products sold most in last 25 years. 
SELECT TOP 5 o.ShipPostalCode, COUNT(o.OrderID) AS CountedOrder
FROM dbo.[Order Details] od JOIN dbo.Orders o ON od.OrderID = o.OrderID JOIN dbo.Products p ON p.ProductID = od.ProductID
WHERE DATEDIFF(year, o.OrderDate, GETDATE()) <= 25
GROUP BY o.ShipPostalCode
ORDER BY CountedOrder DESC

--17. List all city names and number of customers in that city. 
-- I ordered the results by number of customers
SELECT City, COUNT(CustomerID) AS CountedCustomers
FROM dbo.Customers
GROUP BY City
ORDER BY CountedCustomers DESC

--18. List city names which have more than 2 customers, and number of customers in that city
SELECT dt.City, dt.CountedCustomers
FROM (
    SELECT City, COUNT(CustomerID) AS CountedCustomers
    FROM dbo.Customers
    GROUP BY City
)dt
WHERE dt.CountedCustomers > 2
ORDER BY dt.CountedCustomers DESC

--19. List the names of customers who placed orders after 1/1/98 with order date.
SELECT DISTINCT c.ContactName, o.OrderDate
FROM dbo.Orders o JOIN dbo.Customers c ON o.CustomerID = c.CustomerID
WHERE DATEDIFF(year, o.OrderDate, GETDATE()) <= 25

--20. List the names of all customers with most recent order dates
SELECT dt.CustomerName
FROM(
    SELECT DISTINCT c.ContactName AS CustomerName, o. OrderDate AS OrderDate, RANK() OVER (ORDER BY o.OrderDate DESC) RNK
    FROM dbo.Orders o JOIN dbo.Customers c ON o.CustomerID = c.CustomerID
)dt
WHERE RNK = 1

--21. Display the names of all customers  along with the  count of products they bought
SELECT c.ContactName, COUNT(p.ProductID) AS CountedProducts
FROM dbo.Customers c JOIN dbo.Orders o ON c.CustomerID = o.CustomerID
JOIN dbo.[Order Details] od ON o.OrderID = od.OrderID JOIN dbo.Products p ON od.ProductID = p.ProductID
GROUP BY c.ContactName
ORDER BY CountedProducts DESC

--22. Display the customer ids who bought more than 100 Products with count of products.
SELECT dt.CustomerID, dt.CustomerName, dt.CountedProducts
FROM (
    SELECT c.CustomerID AS CustomerID, c.ContactName AS CustomerName, COUNT(p.ProductID) AS CountedProducts
    FROM dbo.Customers c JOIN dbo.Orders o ON c.CustomerID = o.CustomerID
    JOIN dbo.[Order Details] od ON o.OrderID = od.OrderID 
    JOIN dbo.Products p ON od.ProductID = p.ProductID
    GROUP BY c.CustomerID, c.ContactName
)dt
WHERE dt. CountedProducts > 100
ORDER BY CountedProducts DESC

--23. List all of the possible ways that suppliers can ship their products. Display the results as below
SELECT DISTINCT sup.CompanyName AS [Supplier Company Name], s.CompanyName AS [Shipping Company Name] 
FROM Orders o JOIN Shippers s ON o.ShipVia = s.ShipperID JOIN [Order Details] od ON o.OrderID = od.OrderID
JOIN Products p ON p.ProductID = od.ProductID JOIN Suppliers sup ON sup.SupplierID = p.SupplierID

--24. Display the products order each day. Show Order date and Product Name.
SELECT DISTINCT o.OrderDate, p.ProductName
FROM Orders o JOIN [Order Details] od ON o.OrderID = od.OrderID JOIN Products p ON p.ProductID = od.ProductID

--25. Displays pairs of employees who have the same job title.
SELECT e1.EmployeeID, e1.FirstName + ' ' + e1.LastName AS EmployeeName1, e2.EmployeeID, 
        e2.FirstName + ' ' + e2.LastName AS EmployeeName2
FROM Employees e1 JOIN Employees e2 ON e1.Title = e2.Title
WHERE e1.EmployeeID <>e2.EmployeeID

--26. Display all the Managers who have more than 2 employees reporting to them.
SELECT dt.EmployeeName
FROM (
    SELECT  m.FirstName + ' ' + m.LastName AS EmployeeName, COUNT(m.EmployeeID) AS NumOfEmployeesReportTo
    FROM Employees e JOIN Employees m ON e.ReportsTo = m.EmployeeID
    GROUP BY m.FirstName + ' ' + m.LastName
)dt
WHERE dt.NumOfEmployeesReportTo > 2

--27. Display the customers and suppliers by city. The results should have the following columns
SELECT dt.City, dt.Name, dt.ContactName, dt.[Type]
FROM(
    SELECT City, CustomerID AS Name, ContactName, 'Customer' AS Type
    FROM Customers
    UNION
    SELECT City, CompanyName AS Name, ContactName, 'Supplier' AS Type
    FROM Suppliers
)dt
ORDER BY dt.City
