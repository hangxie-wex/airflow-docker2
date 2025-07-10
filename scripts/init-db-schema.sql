

-- Check if the database exists, if not, create it
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'SRSVC')
BEGIN
    CREATE DATABASE [SRSVC];
    PRINT 'DATABASE [SRSVC]  created successfully.';
END
ELSE
BEGIN
    PRINT 'DATABASE [SRSVC] already exists.';
END;
GO

-- Use the newly created or existing database
USE [SRSVC];
GO

-- Creating Aging Schema
IF NOT EXISTS (
    SELECT * FROM sys.schemas WHERE name = N'Aging'
)
BEGIN
    EXEC('CREATE SCHEMA Aging AUTHORIZATION dbo;');
    PRINT 'SCHEMA SCHEMA  created successfully.';
END
ELSE
BEGIN
    PRINT 'SCHEMA Aging already exists.';
END;
GO

-- Creating Expedia Schema
IF NOT EXISTS (
    SELECT * FROM sys.schemas WHERE name = N'Expedia'
)
BEGIN
    EXEC('CREATE SCHEMA Expedia AUTHORIZATION dbo;');
    PRINT 'SCHEMA Expedia  created successfully.';
END
ELSE
BEGIN
    PRINT 'SCHEMA Expedia  already exists.';
END;
GO



