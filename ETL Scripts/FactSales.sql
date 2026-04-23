SELECT
    -- Degenerate keys
    o.OrderID       AS Order_BK,
    bo.BookOrderID  AS LineItem_BK,
    p.PaymentID     AS PaymentLine_BK,

    -- Date BK for DimDate lookup (YYYYMMDD int)
    CAST(CONVERT(CHAR(8), o.OrderDate, 112) AS INT) AS SalesDate,

    -- Business keys for SSIS lookups
    o.StudentID        AS Student_BK,
    bo.BookID          AS Book_BK,
    p.PaymentMethodID  AS Payment_BK,

    -- Measures (line measures)
    bo.Quantity,
    CAST(bo.UnitPrice AS MONEY)        AS UnitPrice,
    CAST(bo.DiscountAmount AS MONEY)   AS DiscountAmount,
    CAST((bo.UnitPrice * bo.Quantity) - bo.DiscountAmount AS MONEY) AS SalesAmount,
    CAST(bo.TaxAmount AS MONEY)        AS TaxAmount,
    CAST(((bo.UnitPrice * bo.Quantity) - bo.DiscountAmount + COALESCE(bo.TaxAmount, 0)) AS MONEY) AS NetSalesAmount,

    -- Payment measure (payment line)
    CAST(p.Amount AS MONEY) AS PaymentAmount

FROM EdureadDB.dbo.BookOrder bo
INNER JOIN EdureadDB.dbo.[Order] o
    ON bo.OrderID = o.OrderID
INNER JOIN EdureadDB.dbo.Payment p
    ON o.OrderID = p.OrderID;