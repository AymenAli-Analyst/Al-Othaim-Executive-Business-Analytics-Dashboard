



ALTER TABLE dbo.AlOthaim_Products
ADD ProfitPerUnit AS (UnitPrice - UnitCost);

ALTER TABLE dbo.AlOthaim_Customers
ADD CustomerTenure AS (YEAR(GETDATE()) - JoinYear);

ALTER TABLE dbo.AlOthaim_Employees
ADD YearsOfService AS (YEAR(GETDATE()) - HireYear);

ALTER TABLE dbo.AlOthaim_Sales_Ratings
ADD TotalCost FLOAT;

ALTER TABLE dbo.AlOthaim_Sales_Ratings
ADD NetProfit FLOAT;

UPDATE S
SET 
    S.TotalCost = S.Quantity * P.UnitCost,
    S.NetProfit = S.SalesAmount - (S.Quantity * P.UnitCost)
FROM dbo.AlOthaim_Sales_Ratings S
INNER JOIN dbo.AlOthaim_Products P ON S.ProductID = P.ProductID;


SELECT
    SUM(SalesAmount) AS Total_Revenue,
    SUM(TotalCost) AS Total_Cost,
    SUM(NetProfit) AS Total_Profit,
    (SUM(NetProfit) / SUM(SalesAmount)) * 100 AS Profit_Margin_Percentage,
    AVG(CAST(Rating AS FLOAT)) AS Average_Customer_Rating
FROM dbo.AlOthaim_Sales_Ratings;



SELECT
    P.Category,
    COUNT(S.TransactionID) AS Total_Orders,
    SUM(S.Quantity) AS Total_Units_Sold,
    SUM(S.SalesAmount) AS Total_Sales,
    SUM(S.NetProfit) AS Total_Profit
FROM dbo.AlOthaim_Sales_Ratings S
INNER JOIN dbo.AlOthaim_Products P ON S.ProductID = P.ProductID
GROUP BY P.Category
ORDER BY Total_Profit DESC;




SELECT
    S.Branch,
    COUNT(S.TransactionID) AS Total_Transactions,
    SUM(S.SalesAmount) AS Total_Sales,
    SUM(S.NetProfit) AS Total_Profit,
    AVG(CAST(S.Rating AS FLOAT)) AS Avg_Branch_Rating
FROM dbo.AlOthaim_Sales_Ratings S
GROUP BY S.Branch
ORDER BY Total_Profit DESC;


SELECT
    C.City,
    C.LoyaltyTier,
    COUNT(DISTINCT S.CustomerID) AS Unique_Customers,
    SUM(S.SalesAmount) AS Total_Sales,
    AVG(CAST(S.Rating AS FLOAT)) AS Avg_Rating
FROM dbo.AlOthaim_Sales_Ratings S
INNER JOIN dbo.AlOthaim_Customers C ON S.CustomerID = C.CustomerID
GROUP BY C.City, C.LoyaltyTier
ORDER BY Total_Sales DESC;



WITH BranchSales AS (
    SELECT Branch, SUM(SalesAmount) AS TotalSales, SUM(NetProfit) AS TotalProfit
    FROM dbo.AlOthaim_Sales_Ratings
    GROUP BY Branch
),
BranchExpenses AS (
    SELECT Branch, SUM(SalarySAR) AS TotalSalaries
    FROM dbo.AlOthaim_Employees
    GROUP BY Branch
)
SELECT
    S.Branch,
    E.TotalSalaries,
    S.TotalSales,
    S.TotalProfit,
    (S.TotalProfit - ISNULL(E.TotalSalaries, 0)) AS Net_Branch_Contribution
FROM BranchSales S
LEFT JOIN BranchExpenses E ON S.Branch = E.Branch
ORDER BY Net_Branch_Contribution DESC;





SELECT
    CAST(Date AS DATE) AS Sales_Date,
    COUNT(TransactionID) AS Daily_Transactions,
    SUM(SalesAmount) AS Daily_Sales,
    SUM(NetProfit) AS Daily_Profit
FROM dbo.AlOthaim_Sales_Ratings
GROUP BY CAST(Date AS DATE)
ORDER BY Sales_Date ASC;



