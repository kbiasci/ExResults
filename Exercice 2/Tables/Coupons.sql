CREATE TABLE [dbo].[Coupons]
(
	[Id] INT NOT NULL PRIMARY KEY  IDENTITY(1,1), 
    [Title] NVARCHAR(50) NULL, 
    [StartDate] DATETIME2 NULL, 
    [EndDate] DATETIME2 NULL, 
    [MaxNbPerUser] INT NULL, 
    [MaxNbInTotal] INT NULL
)
