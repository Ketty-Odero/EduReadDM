USE EduReadDataMart;
GO

SELECT 'DimDate'          AS TableName, COUNT(*) AS RecordCount FROM dbo.DimDate
UNION ALL
SELECT 'DimStudent'       AS TableName, COUNT(*) AS RecordCount FROM dbo.DimStudent
UNION ALL
SELECT 'DimBook'          AS TableName, COUNT(*) AS RecordCount FROM dbo.DimBook
UNION ALL
SELECT 'DimPaymentMethod' AS TableName, COUNT(*) AS RecordCount FROM dbo.DimPaymentMethod
UNION ALL
SELECT 'FactSales'        AS TableName, COUNT(*) AS RecordCount FROM dbo.FactSales;