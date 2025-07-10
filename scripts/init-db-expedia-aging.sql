USE [SRSVC]

/****** Object:  Table [Expedia].[Aging]    Script Date: 7/2/2025 3:14:46 PM ******/

IF NOT EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[Expedia].[Aging]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
    CREATE TABLE [Expedia].[Aging](
        [Billed_Currency] [char](5) NOT NULL,
        [Current_Cycle] [money] NOT NULL,
        [PD_P00] [money] NOT NULL,
        [PD_P01] [money] NOT NULL,
        [PD_P02] [money] NOT NULL,
        [PD_P03] [money] NOT NULL,
        [PD_P04] [money] NOT NULL,
        [PD_P05] [money] NOT NULL,
        [PD_P06] [money] NOT NULL,
        [PD_P07] [money] NOT NULL,
        [Total] [money] NULL,
        [Program] [int] NULL
    ) ON [PRIMARY]
    ALTER TABLE [Expedia].[Aging] ADD  DEFAULT ((489)) FOR [Program]
    PRINT 'Table [Expedia].[Aging]  created successfully.';
END
ELSE
BEGIN
    PRINT 'Table [Expedia].[Aging]  already exists.';
END;
GO

/****** Object:  Table [Expedia].[Aging_Daily]    Script Date: 7/2/2025 3:14:46 PM ******/
IF NOT EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[Expedia].[Aging_Daily]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
    CREATE TABLE [Expedia].[Aging_Daily](
        [Billed_Currency] [varchar](5) NOT NULL,
        [D1_D5] [money] NOT NULL,
        [D6_D10] [money] NOT NULL,
        [D11_D15] [money] NOT NULL,
        [D16_D20] [money] NOT NULL,
        [D21_D25] [money] NOT NULL,
        [D25_D30] [money] NOT NULL,
        [D30_Plus] [money] NOT NULL,
        [Program] [int] NULL
    ) ON [PRIMARY]
    ALTER TABLE [Expedia].[Aging_Daily] ADD  DEFAULT ((489)) FOR [Program]
    PRINT 'Table [Expedia].[Aging_Daily] created successfully.';
END
ELSE
BEGIN
    PRINT 'Table [Expedia].[Aging_Daily] already exists.';
END;
GO

/****** Object:  Table [Expedia].[Aging_Breakdown]    Script Date: 7/2/2025 3:14:46 PM ******/
IF NOT EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[Expedia].[Aging_Breakdown]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
    CREATE TABLE [Expedia].[Aging_Breakdown](
        [Billed_Currency] [char](3) NOT NULL,
        [Trans_Type] [varchar](6) NOT NULL,
        [Current_Cycle] [money] NOT NULL,
        [PD_P00] [money] NOT NULL,
        [PD_P01] [money] NOT NULL,
        [PD_P02] [money] NOT NULL,
        [PD_P03] [money] NOT NULL,
        [PD_P04] [money] NOT NULL,
        [PD_P05] [money] NOT NULL,
        [PD_P06] [money] NOT NULL,
        [PD_P07] [money] NOT NULL,
        [Total] [money] NOT NULL,
        [Program] [int] NULL
    ) ON [PRIMARY]

    ALTER TABLE [Expedia].[Aging_Breakdown] ADD  DEFAULT ((489)) FOR [Program]
    PRINT 'Table [Expedia].[Aging_Breakdown]  created successfully.';
END
ELSE
BEGIN
    PRINT 'Table [Expedia].[Aging_Breakdown]  already exists.';
END;
GO

