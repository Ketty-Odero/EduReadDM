SELECT
    pm.PaymentMethodID AS Payment_BK,
    CAST(pm.MethodName AS NVARCHAR(55)) AS PaymentMethodName,
    CAST(pm.MethodType AS NVARCHAR(55)) AS PaymentType
FROM EdureadDB.dbo.PaymentMethod pm;