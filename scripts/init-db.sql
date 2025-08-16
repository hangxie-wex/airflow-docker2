

-- create_table.sql
-- Check if the database exists, if not, create it
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'TestDB')
BEGIN
    CREATE DATABASE TestDB;
END;
GO

-- Use the newly created or existing database
USE TestDB;
GO

-- Check if the table exists, if not, create it
IF NOT EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[dbo].[MyTable]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
    CREATE TABLE MyTable (
        Id INT PRIMARY KEY IDENTITY(1,1),
        Name NVARCHAR(255) NOT NULL,
        CreatedAt DATETIME DEFAULT GETDATE()
    );
    PRINT 'Table MyTable created successfully.';
END
ELSE
BEGIN
    PRINT 'Table MyTable already exists.';
END;
GO

-- Optional: Insert some sample data
IF NOT EXISTS (SELECT * FROM MyTable WHERE Name = 'Sample Item 1')
BEGIN
    INSERT INTO MyTable (Name) VALUES ('Sample Item 1');
    INSERT INTO MyTable (Name) VALUES ('Sample Item 2');
    PRINT 'Sample data inserted into MyTable.';
END
ELSE
BEGIN
    PRINT 'Sample data already exists in MyTable.';
END;
GO