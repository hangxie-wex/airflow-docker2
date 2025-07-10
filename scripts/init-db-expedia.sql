

USE [SRSVC]

/****** Object:  Table [Expedia].[Files]    Script Date: 7/2/2025 3:14:46 PM ******/
IF NOT EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[Expedia].[Files]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
    CREATE TABLE [Expedia].[Files](
        [FileID] [int] IDENTITY(1,1) NOT NULL,
        [File_Nm] [varchar](75) NOT NULL,
        [File_Type] [varchar](75) NULL,
        [Total_File_Records] [int] NULL,
        [Total_File_Dollars] [money] NULL,
        [Total_Processed_Records] [int] NULL,
        [Total_Processed_Dollars] [money] NULL,
        [Processed] [char](1) NULL,
        [Sheet_Name] [varchar](75) NULL,
        [DB_Processed_Dt] [date] NULL,
        [Archive] [char](1) NULL,
        [Partition_ID] [int] NULL,
        [Remit_Currency_Code] [char](3) NULL,
        [Billing_File_Date] [datetime] NULL,
        [DB_Create_Dt] [datetime] NULL,
        [DB_Created_By] [varchar](50) NULL,
        [Ignore] [bit] NULL,
        [Program] [int] NULL,
    CONSTRAINT [PK_Key] PRIMARY KEY NONCLUSTERED 
    (
        [FileID] ASC
    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
    ) ON [PRIMARY]

    ALTER TABLE [Expedia].[Files] ADD  CONSTRAINT [DF_Files_Archive]  DEFAULT ('N') FOR [Archive]
    ALTER TABLE [Expedia].[Files] ADD  DEFAULT (getdate()) FOR [DB_Create_Dt]
    ALTER TABLE [Expedia].[Files] ADD  DEFAULT (user_name()) FOR [DB_Created_By]
    ALTER TABLE [Expedia].[Files] ADD  DEFAULT ((0)) FOR [Ignore]
    ALTER TABLE [Expedia].[Files] ADD  DEFAULT ((488)) FOR [Program]
    ALTER TABLE [Expedia].[Files]  WITH NOCHECK ADD  CONSTRAINT [Must_Enter_File_Extension] CHECK  (([File_NM] like '%.xlsx' OR [File_Nm] like '%.txt' OR [File_Nm] like '%.xls' OR [File_Nm] like '%.csv'))
    ALTER TABLE [Expedia].[Files] CHECK CONSTRAINT [Must_Enter_File_Extension]
    PRINT 'Table [Expedia].[Files] created successfully.';
END
ELSE
BEGIN
    PRINT 'Table [Expedia].[Files] already exists.';
END;
GO

/****** Object:  Table [Expedia].[BIN_Table]    Script Date: 7/2/2025 3:14:46 PM ******/
IF NOT EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[Expedia].[BIN_Table]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
    CREATE TABLE [Expedia].[BIN_Table](
        [BIN_ID] [int] IDENTITY(1,1) NOT NULL,
        [BIN] [char](6) NOT NULL,
        [Currency_Code] [char](3) NULL,
        [T1_Flag] [char](1) NULL,
        [Client_ID] [varchar](4) NULL,
        [DB_Create_Dt] [date] NOT NULL,
        [Program] [int] NULL,
    PRIMARY KEY CLUSTERED 
    (
        [BIN_ID] ASC
    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
    ) ON [PRIMARY]
    ALTER TABLE [Expedia].[BIN_Table] ADD  DEFAULT (CONVERT([date],getdate(),0)) FOR [DB_Create_Dt]
    ALTER TABLE [Expedia].[BIN_Table] ADD  DEFAULT ((489)) FOR [Program]
    PRINT 'Table [Expedia].[BIN_Table] created successfully.';
END
ELSE
BEGIN
    PRINT 'Table [Expedia].[BIN_Table] already exists.';
END;
GO


/****** Object:  Table [Expedia].[Recon]    Script Date: 7/2/2025 3:14:46 PM ******/
IF NOT EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[Expedia].[Recon]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
    CREATE TABLE [Expedia].[Recon](
        [ReconID] [int] IDENTITY(1,1) NOT NULL,
        [TransID] [varchar](25) NOT NULL,
        [BIN] [char](6) NOT NULL,
        [Post_Dt] [date] NOT NULL,
        [Bill_Curr_Cd] [char](3) NOT NULL,
        [Original_Bal] [money] NOT NULL,
        [Nbr_of_B] [int] NOT NULL,
        [Sum_of_B] [money] NOT NULL,
        [Nbr_of_C] [int] NOT NULL,
        [Sum_of_C] [money] NOT NULL,
        [Nbr_of_D] [int] NOT NULL,
        [Sum_of_D] [money] NOT NULL,
        [Nbr_of_R] [int] NOT NULL,
        [Sum_of_R] [money] NOT NULL,
        [Trans_Bal] [money] NOT NULL,
        [Paid_Dt] [date] NULL,
        [Freeze] [bit] NOT NULL,
        [Bill_Month] [date] NULL,
        [Monthly_Age_Bucket] [varchar](20) NULL,
        [Daily_Age_Bucket] [int] NULL,
        [DSO] [int] NULL,
        [Ignore] [bit] NULL,
        [Bill_File_ID] [int] NULL,
        [BIN_ID] [int] NULL,
        [NPE_ID] [int] NULL,
        [Program] [int] NOT NULL,
    CONSTRAINT [PK_Program_TransID] PRIMARY KEY CLUSTERED 
    (
        [Program] DESC,
        [TransID] ASC
    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
    ) ON [PRIMARY]
    ALTER TABLE [Expedia].[Recon] ADD  DEFAULT ((489)) FOR [Program]
    ALTER TABLE [Expedia].[Recon]  WITH NOCHECK ADD  CONSTRAINT [FK_Recon_BIN_Table] FOREIGN KEY([BIN_ID])
    REFERENCES [Expedia].[BIN_Table] ([BIN_ID])
    ALTER TABLE [Expedia].[Recon] CHECK CONSTRAINT [FK_Recon_BIN_Table]
    PRINT 'Table [Expedia].[Recon] created successfully.';
END
ELSE
BEGIN
    PRINT 'Table [Expedia].[Recon] already exists.';
END;
GO

/****** Object:  Table [Expedia].[Remit]    Script Date: 7/2/2025 3:14:46 PM ******/
IF NOT EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[Expedia].[Remit]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
    CREATE TABLE [Expedia].[Remit](
        [Remit_ID] [int] IDENTITY(1,1) NOT NULL,
        [Seq] [float] NULL,
        [TransID] [varchar](25) NOT NULL,
        [TransType] [char](1) NULL,
        [SettlementCurrency] [char](3) NULL,
        [InvoiceAmt] [money] NULL,
        [PaidAmt] [money] NULL,
        [ConvertedCurrency] [char](3) NULL,
        [ConvertedAmount] [money] NULL,
        [RemitDate] [date] NULL,
        [ReceiveDate] [date] NULL,
        [PlogID] [char](18) NULL,
        [PaymentType] [char](10) NULL,
        [Remark] [char](25) NULL,
        [DB_Create_Dt] [date] NULL,
        [Pymnt_Applied] [bit] NULL,
        [PaymentReconAmt] [money] NULL,
        [Comments] [varchar](75) NULL,
        [VendorInvoiceNbr] [varchar](75) NULL,
        [PaymentRefNbr] [varchar](75) NULL,
        [BIN] [char](6) NULL,
        [FileID] [int] NOT NULL,
        [Program] [int] NULL,
    CONSTRAINT [PK_Remit_1] PRIMARY KEY CLUSTERED 
    (
        [Remit_ID] ASC
    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
    ) ON [PRIMARY]
    ALTER TABLE [Expedia].[Remit] ADD  DEFAULT ((489)) FOR [Program]
    ALTER TABLE [Expedia].[Remit]  WITH NOCHECK ADD  CONSTRAINT [FK_Remit_Files] FOREIGN KEY([FileID])
    REFERENCES [Expedia].[Files] ([FileID])
    ALTER TABLE [Expedia].[Remit] CHECK CONSTRAINT [FK_Remit_Files]
    ALTER TABLE [Expedia].[Remit]  WITH NOCHECK ADD  CONSTRAINT [FK_Remit_Recon] FOREIGN KEY([Program], [TransID])
    REFERENCES [Expedia].[Recon] ([Program], [TransID])
    NOT FOR REPLICATION 
    ALTER TABLE [Expedia].[Remit] NOCHECK CONSTRAINT [FK_Remit_Recon]

    PRINT 'Table [Expedia].[Remit] created successfully.';
END
ELSE
BEGIN
    PRINT 'Table [Expedia].[Remit]already exists.';
END;
GO

/****** Object:  Table [Expedia].[Recon_BIN_Dly_Bal]    Script Date: 7/2/2025 3:14:46 PM ******/
IF NOT EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[Expedia].[Recon_BIN_Dly_Bal]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
    CREATE TABLE [Expedia].[Recon_BIN_Dly_Bal](
        [BIN_ID] [int] NOT NULL,
        [Process_Date] [date] NOT NULL,
        [Nbr_of_Crdts] [int] NOT NULL,
        [Crdt_Bal_Outstanding] [money] NOT NULL,
        [Nbr_of_Dbts] [int] NOT NULL,
        [Dbt_Bal_Outstanding] [money] NOT NULL,
        [Ttl_Trans_Outstanding] [int] NOT NULL,
        [Ttl_Bal_Outstanding] [money] NOT NULL,
        [DB_Create_Dt] [date] NOT NULL,
        [TSYS_Balance] [money] NULL,
        [Variance] [money] NULL,
        [RBDBID] [int] IDENTITY(1,1) NOT NULL,
        [Program] [int] NOT NULL,
    CONSTRAINT [PK_BINDt_Program] PRIMARY KEY NONCLUSTERED 
    (
        [Process_Date] ASC,
        [BIN_ID] ASC,
        [Program] ASC
    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
    ) ON [PRIMARY]
    ALTER TABLE [Expedia].[Recon_BIN_Dly_Bal] ADD  DEFAULT (CONVERT([date],getdate(),0)) FOR [DB_Create_Dt]
    ALTER TABLE [Expedia].[Recon_BIN_Dly_Bal] ADD  DEFAULT ((489)) FOR [Program]
    ALTER TABLE [Expedia].[Recon_BIN_Dly_Bal]  WITH CHECK ADD  CONSTRAINT [FK_RBDB_to_BIN_Table] FOREIGN KEY([BIN_ID])
    REFERENCES [Expedia].[BIN_Table] ([BIN_ID])
    ALTER TABLE [Expedia].[Recon_BIN_Dly_Bal] CHECK CONSTRAINT [FK_RBDB_to_BIN_Table]
    PRINT 'Table [Expedia].[Recon_BIN_Dly_Bal] created successfully.';
END
ELSE
BEGIN
    PRINT 'Table [Expedia].[Recon_BIN_Dly_Bal] already exists.';
END;
GO

/****** Object:  Table [Expedia].[Billing_File_Overview]    Script Date: 7/2/2025 3:14:46 PM ******/
IF NOT EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[Expedia].[Billing_File_Overview]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
    CREATE TABLE [Expedia].[Billing_File_Overview](
        [bill_file_nm] [varchar](75) NULL,
        [nbr_of_billed_trans] [float] NULL,
        [ttl_billed_amt] [float] NULL,
        [ttl_trans_settled] [float] NULL,
        [ttl_amt_settled] [float] NULL,
        [nbr_of_b_items] [float] NULL,
        [ttl_b_items] [float] NULL,
        [nbr_of_c_items] [float] NULL,
        [ttl_c_items] [float] NULL,
        [nbr_of_d_items] [float] NULL,
        [ttl_d_items] [float] NULL,
        [nbr_of_r_items] [float] NULL,
        [ttl_r_items] [float] NULL,
        [ttl_remit_items_applied] [float] NULL,
        [ttl_trans_outstanding] [float] NULL,
        [ttl_bal_outstanding] [float] NULL,
        [Program] [int] NULL
    ) ON [PRIMARY]
    ALTER TABLE [Expedia].[Billing_File_Overview] ADD  DEFAULT ((489)) FOR [Program]
    ALTER TABLE [Expedia].[Billing_File_Overview]  WITH NOCHECK ADD  CONSTRAINT [FK_Billing_File_Overview_Files] FOREIGN KEY([bill_file_nm])
    REFERENCES [Expedia].[Files] ([File_Nm])
    ALTER TABLE [Expedia].[Billing_File_Overview] CHECK CONSTRAINT [FK_Billing_File_Overview_Files]
    PRINT 'Table [Expedia].[Billing_File_Overview]  created successfully.';
END
ELSE
BEGIN
    PRINT 'Table [Expedia].[Billing_File_Overview]  already exists.';
END;
GO

/****** Object:  Table [Expedia].[Billing_File_Monitor_Ctrl]    Script Date: 7/2/2025 3:14:46 PM ******/
IF NOT EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[Expedia].[Billing_File_Monitor_Ctrl]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
    CREATE TABLE [Expedia].[Billing_File_Monitor_Ctrl](
        [BFMCID] [int] IDENTITY(1,1) NOT NULL,
        [FileID] [int] NOT NULL,
        [File_Day] [varchar](10) NOT NULL,
        [Last_File_Items_Billed] [int] NULL,
        [Last_File_Variance] [decimal](18, 3) NULL,
        [Avg_Rolling_File_Day_Items] [int] NULL,
        [Avg_Rolling_File_Day_Variance] [decimal](18, 3) NULL,
        [DB_Created_Dt] [datetime] NOT NULL,
        [DB_Created_By] [varchar](50) NOT NULL,
        [Program] [int] NULL,
    PRIMARY KEY CLUSTERED 
    (
        [BFMCID] ASC
    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
    ) ON [PRIMARY]
    ALTER TABLE [Expedia].[Billing_File_Monitor_Ctrl] ADD  DEFAULT (getdate()) FOR [DB_Created_Dt]
    ALTER TABLE [Expedia].[Billing_File_Monitor_Ctrl] ADD  DEFAULT (user_name()) FOR [DB_Created_By]
    ALTER TABLE [Expedia].[Billing_File_Monitor_Ctrl] ADD  DEFAULT ((489)) FOR [Program]
    ALTER TABLE [Expedia].[Billing_File_Monitor_Ctrl]  WITH CHECK ADD FOREIGN KEY([FileID])
    REFERENCES [Expedia].[Files] ([FileID])
    PRINT 'Table [Expedia].[Billing_File_Monitor_Ctrl] created successfully.';
END
ELSE
BEGIN
    PRINT 'Table [Expedia].[Billing_File_Monitor_Ctrl] already exists.';
END;
GO

/****** Object:  Table [Expedia].[Billed_Transactions]    Script Date: 7/2/2025 3:14:46 PM ******/
IF NOT EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[Expedia].[Billed_Transactions]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
    CREATE TABLE [Expedia].[Billed_Transactions](
        [Bill_ID] [int] IDENTITY(1,1) NOT NULL,
        [Corp_CCN] [char](16) NULL,
        [Trans_Type] [char](1) NULL,
        [TransID] [varchar](25) NOT NULL,
        [CCN] [char](16) NULL,
        [PLOGID] [char](18) NULL,
        [PLOG_Trans_Amt] [money] NULL,
        [PLOG_Dt] [date] NULL,
        [Posting_Dt] [date] NULL,
        [Trans_Dt] [date] NULL,
        [Mrch_Accpt_Id] [char](15) NULL,
        [Mrch_City] [char](50) NULL,
        [Mrch_St] [char](3) NULL,
        [Mrch_Zip] [char](15) NULL,
        [Mrch_Cntry_Cd] [char](3) NULL,
        [Srce_Curr_Cd] [char](3) NULL,
        [Bill_Curr_Cd] [char](3) NULL,
        [Srce_Amt] [money] NULL,
        [Bill_Amt] [money] NULL,
        [Ref_Nbr] [char](23) NULL,
        [SIC_MCC_Cd] [char](4) NULL,
        [Org_Amt] [money] NULL,
        [Auth_Nbr] [char](6) NULL,
        [Conv_Rt] [numeric](18, 8) NULL,
        [UDF_1] [float] NULL,
        [UDF_2] [float] NULL,
        [UDF_3] [float] NULL,
        [Frgn_Exch_Fee_Rt] [numeric](18, 8) NULL,
        [Frgn_Exch_Fee_Amt] [money] NULL,
        [Crss_Brdr_Fee_Rt] [numeric](18, 8) NULL,
        [Crss_Brdr_Fee_Amt] [money] NULL,
        [DB_Create_Dt] [date] NULL,
        [Processed] [bit] NULL,
        [Manual] [bit] NULL,
        [Mrch_Descr] [varchar](100) NULL,
        [Comments] [varchar](100) NULL,
        [Org_TransID] [varchar](25) NULL,
        [FileID] [int] NOT NULL,
        [Bill_ID_New] [bigint] NULL,
        [UDF_4] [varchar](99) NULL,
        [Program] [int] NOT NULL,
    CONSTRAINT [Cx_PK_BT_TransID] PRIMARY KEY CLUSTERED 
    (
        [Program] DESC,
        [TransID] ASC
    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
    ) ON [PRIMARY]
    ALTER TABLE [Expedia].[Billed_Transactions] ADD  DEFAULT ((489)) FOR [Program]
    ALTER TABLE [Expedia].[Billed_Transactions]  WITH NOCHECK ADD  CONSTRAINT [FK_Billed_Transactions_Files] FOREIGN KEY([FileID])
    REFERENCES [Expedia].[Files] ([FileID])
    ALTER TABLE [Expedia].[Billed_Transactions] CHECK CONSTRAINT [FK_Billed_Transactions_Files]
    ALTER TABLE [Expedia].[Billed_Transactions]  WITH NOCHECK ADD  CONSTRAINT [FK_Billed_Transactions_Recon] FOREIGN KEY([Program], [TransID])
    REFERENCES [Expedia].[Recon] ([Program], [TransID])
    NOT FOR REPLICATION 
    ALTER TABLE [Expedia].[Billed_Transactions] NOCHECK CONSTRAINT [FK_Billed_Transactions_Recon]
    PRINT 'Table [Expedia].[Billed_Transactions] created successfully.';
END
ELSE
BEGIN
    PRINT 'Table [Expedia].[Billed_Transactions]le already exists.';
END;
GO

/****** Object:  Table [Expedia].[Bill_Accts]    Script Date: 7/2/2025 3:14:46 PM ******/
IF NOT EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[Expedia].[Bill_Accts]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
    CREATE TABLE [Expedia].[Bill_Accts](
        [BillAcctID] [int] IDENTITY(1,1) NOT NULL,
        [Billing_Acct_CCN] [char](16) NOT NULL,
        [Billing_Acct_Sts] [bit] NOT NULL,
        [DB_Create_Dt] [date] NOT NULL,
        [Entered_By] [varchar](25) NOT NULL,
        [BIN_ID] [int] NULL,
        [Currency_Code] [char](3) NULL,
        [Program] [int] NULL,
    PRIMARY KEY CLUSTERED 
    (
        [BillAcctID] ASC
    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
    ) ON [PRIMARY]

    ALTER TABLE [Expedia].[Bill_Accts] ADD  DEFAULT ((1)) FOR [Billing_Acct_Sts]
    ALTER TABLE [Expedia].[Bill_Accts] ADD  DEFAULT (CONVERT([date],getdate(),0)) FOR [DB_Create_Dt]
    ALTER TABLE [Expedia].[Bill_Accts] ADD  DEFAULT (user_name()) FOR [Entered_By]
    ALTER TABLE [Expedia].[Bill_Accts] ADD  DEFAULT ((489)) FOR [Program]
    ALTER TABLE [Expedia].[Bill_Accts]  WITH NOCHECK ADD  CONSTRAINT [FK_Bill_Acct_to_BIN_Table] FOREIGN KEY([BIN_ID])
    REFERENCES [Expedia].[BIN_Table] ([BIN_ID])
    ALTER TABLE [Expedia].[Bill_Accts] CHECK CONSTRAINT [FK_Bill_Acct_to_BIN_Table]
    PRINT 'Table [Expedia].[Bill_Accts] created successfully.';
END
ELSE
BEGIN
    PRINT 'Table [Expedia].[Bill_Accts] already exists.';
END;
GO

/****** Object:  Table [Expedia].[Factoring_Currencies]    Script Date: 7/2/2025 3:14:46 PM ******/
IF NOT EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[Expedia].[Factoring_Currencies]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
    CREATE TABLE [Expedia].[Factoring_Currencies](
        [CurrID] [int] IDENTITY(1,1) NOT NULL,
        [Currency] [char](3) NOT NULL,
        [DB_Created_By] [varchar](25) NOT NULL,
        [DB_Created_Dt] [datetime] NOT NULL,
        [Bank_Name] [varchar](63) NOT NULL,
        [Account_Name] [varchar](63) NOT NULL,
        [Bank_Acct_Nbr] [varchar](16) NOT NULL,
        [Routing_Nbr] [varchar](9) NOT NULL,
        [SWIFT] [varchar](120) NULL,
        [CHIPS_Bank] [varchar](6) NULL,
    PRIMARY KEY CLUSTERED 
    (
        [CurrID] ASC
    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
    ) ON [PRIMARY]
    ALTER TABLE [Expedia].[Factoring_Currencies] ADD  DEFAULT (user_name()) FOR [DB_Created_By]
    ALTER TABLE [Expedia].[Factoring_Currencies] ADD  DEFAULT (getdate()) FOR [DB_Created_Dt]

    PRINT 'Table [Expedia].[Factoring_Currencies] created successfully.';
END
ELSE
BEGIN
    PRINT 'Table [Expedia].[Factoring_Currencies] already exists.';
END;
GO

/****** Object:  Table [Expedia].[Pending_Payments]    Script Date: 7/2/2025 3:14:46 PM ******/
IF NOT EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[Expedia].[Pending_Payments]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
    CREATE TABLE [Expedia].[Pending_Payments](
        [PendingPaymentID] [int] IDENTITY(1,1) NOT NULL,
        [PaymentRefNbr] [varchar](75) NOT NULL,
        [PaymentDate] [date] NOT NULL,
        [SettlementCurrency] [char](3) NOT NULL,
        [PaymentAmt] [money] NOT NULL,
        [Processed] [bit] NOT NULL,
        [RemitFileID] [int] NULL,
        [Entered_By] [varchar](25) NOT NULL,
        [Entered_Date] [datetime] NOT NULL,
        [Posted_TSYS] [bit] NOT NULL,
        [Bank_Fee] [money] NOT NULL,
        [TSYS_Post_Date] [date] NULL,
        [Bank_Fee_Chargeoff_Date] [date] NULL,
        [Program] [int] NULL,
    CONSTRAINT [PK_Idx_PendingPaymentID] PRIMARY KEY CLUSTERED 
    (
        [PendingPaymentID] ASC
    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
    ) ON [PRIMARY]
    ALTER TABLE [Expedia].[Pending_Payments] ADD  DEFAULT ((0)) FOR [Processed]
    ALTER TABLE [Expedia].[Pending_Payments] ADD  DEFAULT (user_name()) FOR [Entered_By]
    ALTER TABLE [Expedia].[Pending_Payments] ADD  DEFAULT (getdate()) FOR [Entered_Date]
    ALTER TABLE [Expedia].[Pending_Payments] ADD  DEFAULT ((0)) FOR [Posted_TSYS]
    ALTER TABLE [Expedia].[Pending_Payments] ADD  DEFAULT ((0)) FOR [Bank_Fee]
    ALTER TABLE [Expedia].[Pending_Payments] ADD  DEFAULT ((489)) FOR [Program]
    PRINT 'Table [Expedia].[Pending_Payments] created successfully.';
END
ELSE
BEGIN
    PRINT 'Table [Expedia].[Pending_Payments] already exists.';
END;
GO
