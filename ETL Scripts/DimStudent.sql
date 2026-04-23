SELECT
    s.StudentID AS Student_BK,

    CAST(s.FirstName AS NVARCHAR(55)) AS FirstName,
    CAST(s.LastName  AS NVARCHAR(55)) AS LastName,

    CAST(CONCAT(CAST(s.FirstName AS NVARCHAR(55)), N' ', CAST(s.LastName AS NVARCHAR(55))) AS NVARCHAR(125)) AS FLName,

    /* Deriving Age from DateOfBirth */
    CAST(
        DATEDIFF(YEAR, s.DateOfBirth, GETDATE())
        - CASE
            WHEN DATEADD(YEAR,
                         DATEDIFF(YEAR, s.DateOfBirth, GETDATE()),
                         s.DateOfBirth) > GETDATE()
            THEN 1
            ELSE 0
          END
    AS NVARCHAR(20)) AS Age,

    CAST(s.Gender   AS NVARCHAR(55)) AS Gender,
    CAST(s.City     AS NVARCHAR(55)) AS City,
    CAST(s.[State]  AS NVARCHAR(55)) AS [State],
    CAST(s.[Address] AS NVARCHAR(55)) AS [Address]

FROM EduReadDB.dbo.Student s;
