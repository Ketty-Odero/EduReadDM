/*
  EduReadDataMart Build Script
  (Tables: DimDate, DimStudent, DimEmployee, DimPublisher, DimBook,
           DimPaymentType, FactSales
   Views: DimOrderDate, DimShipDate, DimDeliveryDate)
*/

-- Create the database.

IF NOT EXISTS(SELECT * FROM sys.databases
	WHERE NAME = N'EduReadDataMart')
	CREATE DATABASE EduReadDataMart
GO

-- Switch to the new database.

USE EduReadDataMart;
GO


/*
  Drop the existing tables (FACT first, then DIM)
*/


IF EXISTS(
	SELECT *
	FROM sys.tables
	WHERE name = N'FactSales'
)
	DROP TABLE FactSales;


IF EXISTS(
	SELECT *
	FROM sys.tables
	WHERE name = N'DimPaymentMethod'
)
	DROP TABLE DimPaymentMethod;

IF EXISTS(
	SELECT *
	FROM sys.tables
	WHERE name = N'DimBook'
)
	DROP TABLE DimBook;

IF EXISTS(
	SELECT *
	FROM sys.tables
	WHERE name = N'DimStudent'
)
	DROP TABLE DimStudent;

IF EXISTS(
	SELECT *
	FROM sys.tables
	WHERE name = N'DimDate'
)
	DROP TABLE DimDate;
GO


/*
  Create the tables
*/

CREATE TABLE DimDate (
	Date_SK				INT CONSTRAINT pk_date_key PRIMARY KEY, -- Full date as an integer in YYYYMMDD format
	Date				DATE, -- Full date as a DATE format
	FullDate			NCHAR(10), -- Date in MM-DD-YYYY format
	DayOfMonth			INT, -- Day number of the month
	DayName				NVARCHAR(9), -- Monday, Tuesday, etc. 
	DayOfWeek			INT, -- Sunday = 1 and Saturday = 7
	DayOfWeekInMonth	INT, -- 1st Monday or 2nd Monday in month
	DayOfWeekInYear		INT, -- Day of the week in the year
	DayOfQuarter		INT, -- Day of the quarter
	DayOfYear			INT, -- Day of the year
	WeekOfMonth			INT,-- Week number of the month 
	WeekOfQuarter		INT, -- Week number of the quarter
	WeekOfYear			INT,-- Week number of the year
	Month				INT, -- Number of the month (eg., 1 = January)
	MonthName			NVARCHAR(9), -- Full name of the month (e.g., January)
	MonthOfQuarter		INT, -- Month number belongs to the quarter
	Quarter				NCHAR(2), -- Quarter number
	QuarterName			NCHAR(2), -- Quarter number as words (e.g., First)
	Year				INT, -- Year of the date
	CYearName			NCHAR(7), -- CY + Year (e.g., CY 2026)
	FYearName			NCHAR(7), -- FY + Year (e.g., FY 2026)
	MonthYear			NCHAR(10), -- Month abbreviation + year (e.g., Jan-2026)
	MMYYYY				INT, -- Date in MMYYYY format
	FirstDayOfMonth		DATE, -- First date of the month
	LastDayOfMonth		DATE, -- Last day of the month
	FirstDayOfQuarter	DATE, -- First day of the quarter
	LastDayOfQuarter	DATE, -- Last day of the quarter
	FirstDayOfYear		DATE, -- First day of the year
	LastDayOfYear		DATE, -- Last day of the year
	IsWeekday			BIT, -- 0 = Weekend, 1 = Weekday,
	IsWeekdayName		NVARCHAR(55), -- Weekend, Weekday
	IsHoliday			BIT, -- 1 = National Holiday, 0 = Not a National Holiday
	IsHolidayName		NVARCHAR(55), -- National Holiday or Not a National Holiday
	Holiday				NVARCHAR(55), -- Name of Holiday in US
	Season				INT, -- Number of season (1 = Fall to 4 = Summer)
	SeasonName			NVARCHAR(10) -- Name of the season
);

GO


CREATE TABLE DimStudent (
	Student_SK			INT IDENTITY CONSTRAINT pk_student_key PRIMARY KEY,
	Student_BK			INT NOT NULL,              -- from source database StudentID
	FirstName			NVARCHAR(55) NOT NULL,
	LastName			NVARCHAR(55) NOT NULL,
	FLName				NVARCHAR(125) NOT NULL,    -- First Last
	Age                 NVARCHAR(20) NOT NULL,
	Gender				NVARCHAR(55) NULL,
	City				NVARCHAR(55) NOT NULL,
	[State]				NVARCHAR(55) NOT NULL,
	[Address]			NVARCHAR(55) NOT NULL
);
GO




-- Book dimension 
CREATE TABLE DimBook (
	Book_SK				INT IDENTITY CONSTRAINT pk_book_key PRIMARY KEY,
	Book_BK				INT NOT NULL,              -- from source OLTP BookID
	BookTitle			NVARCHAR(200) NOT NULL,
	Genre				NVARCHAR(55) NOT NULL,
	Category			NVARCHAR(55) NOT NULL,
	Author				NVARCHAR(150) NULL,
	Publisher		    NVARCHAR(150) NULL
	
);
GO


CREATE TABLE DimPaymentMethod (
	Payment_SK		            INT IDENTITY CONSTRAINT pk_payment_type_key PRIMARY KEY,
	Payment_BK		            INT NOT NULL,              -- simple numeric business key
	PaymentMethodName			NVARCHAR(55) NOT NULL,     -- Visa, Mastercard, American Express, ApplePay, GooglePay, SubscriptionCredit
	PaymentType		            NVARCHAR(55) NOT NULL      -- Card, DigitalWallet, Credit
);
GO


/*
  Facts
*/

-- Fact grain: 1 row per (OrderID, LineItemID) = one book line in an order
CREATE TABLE FactSales
(
    -- Degenerate keys (from OLTP)
    Order_BK        INT NOT NULL,
    LineItem_BK     INT NOT NULL,
    PaymentLine_BK  INT NOT NULL,  -- OLTP Payment.PaymentID (supports split payments)

    -- Date key for DimDate
    SalesDate       INT CONSTRAINT fk_order_date_key
                        FOREIGN KEY REFERENCES DimDate(Date_SK) NOT NULL,

    -- Dimension surrogate keys
    Student_SK      INT CONSTRAINT fk_student_key
                        FOREIGN KEY REFERENCES DimStudent(Student_SK) NOT NULL,

    Payment_SK      INT CONSTRAINT fk_paymentmethod_key
                        FOREIGN KEY REFERENCES DimPaymentMethod(Payment_SK) NOT NULL,

    Book_SK         INT CONSTRAINT fk_book_key
                        FOREIGN KEY REFERENCES DimBook(Book_SK) NOT NULL,

    -- Measures (line measures)
    Quantity        INT NOT NULL,
    UnitPrice       MONEY NOT NULL,
    DiscountAmount  MONEY NOT NULL,
    SalesAmount     MONEY NOT NULL,
    TaxAmount       MONEY NULL,
    NetSalesAmount  MONEY NOT NULL,

    -- Payment measure (payment line)
    PaymentAmount   MONEY NOT NULL,

    CONSTRAINT pk_factsales PRIMARY KEY (Order_BK, LineItem_BK, PaymentLine_BK)
);
GO

