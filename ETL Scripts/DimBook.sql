SELECT
    b.BookID AS Book_BK,
    CAST(b.BookTitle AS NVARCHAR(200))      AS BookTitle,
    CAST(b.Category  AS NVARCHAR(55))       AS Category,
    CAST(b.Genre     AS NVARCHAR(55))       AS Genre,
    COALESCE(a_one.AuthorName, N'Unknown')  AS Author,
    CAST(p.PublisherName AS NVARCHAR(150))  AS Publisher
FROM EdureadDB.dbo.Book b
LEFT JOIN EdureadDB.dbo.Publisher p
    ON b.PublisherID = p.PublisherID
LEFT JOIN (
    SELECT
        bba.BookID,
        CAST(a.FirstName AS NVARCHAR(55)) + N' ' + CAST(a.LastName AS NVARCHAR(55)) AS AuthorName,
        ROW_NUMBER() OVER (PARTITION BY bba.BookID ORDER BY bba.AuthorID) AS rn
    FROM EdureadDB.dbo.BookByAuthor bba
    JOIN EdureadDB.dbo.Author a
        ON bba.AuthorID = a.AuthorID
) a_one
    ON b.BookID = a_one.BookID
   AND a_one.rn = 1;