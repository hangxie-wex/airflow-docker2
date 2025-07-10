
/****** Object:  Table [Aging].[LOV]    Script Date: 7/3/2025 11:48:24 AM ******/
IF NOT EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[Aging].[LOV]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
    CREATE TABLE [Aging].[LOV](
        [LOVID] [int] IDENTITY(1,1) NOT NULL,
        [Field_Name] [varchar](50) NOT NULL,
        [Field_Value] [varchar](50) NOT NULL,
        [Status] [bit] NOT NULL,
        [Sort_Nbr] [int] NOT NULL,
        [Table_Name] [varchar](25) NOT NULL,
        [LOB] [varchar](25) NOT NULL,
        [DB_Create_Dt] [datetime] NOT NULL,
        [DB_Created_By] [varchar](50) NOT NULL,
        [ReportingValue] [varchar](100) NULL,
        [PassthroughValue] [varchar](50) NULL,
        CONSTRAINT [PK_LOV] PRIMARY KEY CLUSTERED 
    (
        [LOVID] ASC
    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
    ) ON [PRIMARY]

    ALTER TABLE [Aging].[LOV] ADD  DEFAULT ('All') FOR [LOB]
    ALTER TABLE [Aging].[LOV] ADD  DEFAULT (getdate()) FOR [DB_Create_Dt]
    ALTER TABLE [Aging].[LOV] ADD  DEFAULT (user_name()) FOR [DB_Created_By]

    PRINT 'Table [Aging].[LOV] created successfully.';
END
ELSE
BEGIN
    PRINT 'Table [Aging].[LOV] already exists.';
END;
GO

/****** Object:  Table [Aging].[FTP_File_Inventory]    Script Date: 7/2/2025 3:14:46 PM ******/
IF NOT EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[Aging].[FTP_File_Inventory]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
    CREATE TABLE [Aging].[FTP_File_Inventory](
        [FTPFileID] [int] IDENTITY(1,1) NOT NULL,
        [Process_Name] [varchar](255) NOT NULL,
        [Data_Source] [varchar](255) NOT NULL,
        [FTP_Site] [varchar](255) NOT NULL,
        [FTP_User] [varchar](255) NOT NULL,
        [FTP_Password] [varchar](255) NOT NULL,
        [FTP_Directory] [varchar](255) NOT NULL,
        [FTP_File_Freq_Days] [int] NULL,
        [FTP_Root_Filename] [varchar](255) NOT NULL,
        [Transfer_Directory] [varchar](255) NOT NULL,
        [Transfer_Name] [varchar](255) NOT NULL,
        [Transfer_Name_Add_Dt] [bit] NOT NULL,
        [Decryption_Needed] [bit] NOT NULL,
        [Decrypt_Key] [varchar](255) NOT NULL,
        [Decrypt_Password] [varchar](255) NOT NULL,
        [Decrypt_File_Type] [varchar](255) NOT NULL,
        [DB_Create_Date] [datetime] NOT NULL,
        [DB_Create_User] [varchar](50) NOT NULL,
        [ProxyAuthNeeded] [bit] NOT NULL,
        [FTP_Dir_Method] [int] NOT NULL,
        [Record_Status] [char](1) NOT NULL,
        [Last_Scanned] [datetime] NULL,
        [Last_Run_Time_Seconds] [int] NULL,
        [EMail_Notification] [bit] NOT NULL,
        [Email_Notif_Recip] [varchar](500) NULL,
        [SAS_Processing] [bit] NOT NULL,
        [SAS_Routine] [varchar](200) NULL,
        [WEXEU_Email] [bit] NOT NULL,
        [Scan_Type] [int] NOT NULL,
        [Output_FTP_Site] [varchar](255) NULL,
        [Output_FTP_User] [varchar](255) NULL,
        [Output_FTP_Password] [varchar](255) NULL,
        [Output_FTP_Directory] [varchar](255) NULL,
        [FTP_Delivery_Flag] [bit] NOT NULL,
        [Unzip_Req] [bit] NOT NULL,
        [Move_Source_File] [bit] NOT NULL,
        [Unzip_Directory] [varchar](255) NULL,
        [Archive_Files] [bit] NOT NULL,
        [Archive_Days] [int] NULL,
        [ProcessingStatus] [char](1) NULL,
        [Run_Order] [int] NULL,
    PRIMARY KEY CLUSTERED 
    (
        [FTPFileID] ASC
    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
    ) ON [PRIMARY]

    ALTER TABLE [Aging].[FTP_File_Inventory] ADD  DEFAULT ((0)) FOR [Transfer_Name_Add_Dt]
    ALTER TABLE [Aging].[FTP_File_Inventory] ADD  DEFAULT ((1)) FOR [Decryption_Needed]
    ALTER TABLE [Aging].[FTP_File_Inventory] ADD  DEFAULT (getdate()) FOR [DB_Create_Date]
    ALTER TABLE [Aging].[FTP_File_Inventory] ADD  DEFAULT (user_name()) FOR [DB_Create_User]
    ALTER TABLE [Aging].[FTP_File_Inventory] ADD  DEFAULT ((0)) FOR [ProxyAuthNeeded]
    ALTER TABLE [Aging].[FTP_File_Inventory] ADD  DEFAULT ((280)) FOR [FTP_Dir_Method]
    ALTER TABLE [Aging].[FTP_File_Inventory] ADD  DEFAULT ('A') FOR [Record_Status]
    ALTER TABLE [Aging].[FTP_File_Inventory] ADD  DEFAULT ((0)) FOR [EMail_Notification]
    ALTER TABLE [Aging].[FTP_File_Inventory] ADD  DEFAULT ((0)) FOR [SAS_Processing]
    ALTER TABLE [Aging].[FTP_File_Inventory] ADD  DEFAULT ((0)) FOR [WEXEU_Email]
    ALTER TABLE [Aging].[FTP_File_Inventory] ADD  DEFAULT ((303)) FOR [Scan_Type]
    ALTER TABLE [Aging].[FTP_File_Inventory] ADD  DEFAULT ((0)) FOR [FTP_Delivery_Flag]
    ALTER TABLE [Aging].[FTP_File_Inventory] ADD  DEFAULT ((0)) FOR [Unzip_Req]
    ALTER TABLE [Aging].[FTP_File_Inventory] ADD  DEFAULT ((0)) FOR [Move_Source_File]
    ALTER TABLE [Aging].[FTP_File_Inventory] ADD  DEFAULT ((0)) FOR [Archive_Files]
    ALTER TABLE [Aging].[FTP_File_Inventory] ADD  DEFAULT ('I') FOR [ProcessingStatus]
    ALTER TABLE [Aging].[FTP_File_Inventory]  WITH CHECK ADD  CONSTRAINT [FK_Scan_Type_LOV] FOREIGN KEY([Scan_Type])
    REFERENCES [Aging].[LOV] ([LOVID])
    ALTER TABLE [Aging].[FTP_File_Inventory] CHECK CONSTRAINT [FK_Scan_Type_LOV]
    PRINT 'Table [Aging].[FTP_File_Inventory] created successfully.';
END
ELSE
BEGIN
    PRINT 'Table [Aging].[FTP_File_Inventory] already exists.';
END;
GO

/****** Object:  Table [Aging].[FTP_Incoming_Files]    Script Date: 7/2/2025 3:14:46 PM ******/
IF NOT EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[Aging].[FTP_Incoming_Files]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
    CREATE TABLE [Aging].[FTP_Incoming_Files](
        [IncomingFileID] [int] IDENTITY(1,1) NOT NULL,
        [FTPFileID] [int] NOT NULL,
        [FTP_Filename] [varchar](255) NOT NULL,
        [FTP_Moddate] [datetime] NOT NULL,
        [Decrypted_File] [bit] NOT NULL,
        [Decrypt_File_Nm] [varchar](255) NULL,
        [Download_Date] [datetime] NOT NULL,
        [File_Record_Count] [int] NULL,
        [Downloaded] [bit] NULL,
        [DB_Create_Dt] [datetime] NOT NULL,
        [DB_Create_User] [varchar](50) NULL,
        [Email_Notif_Sent] [bit] NOT NULL,
        [Email_Notif_Dt] [datetime] NULL,
        [File_Moved] [bit] NOT NULL,
        [SAS_Process_Complete] [bit] NOT NULL,
        [SAS_Process_Complete_Dt] [datetime] NULL,
        [WEXEU_Email_Sent] [bit] NULL,
        [WEXEU_Email_Date_Sent] [datetime] NULL,
        [FTP_Transmit_Success] [bit] NOT NULL,
        [FTP_Transmit_Date] [datetime] NULL,
        [Unzip_Success] [bit] NOT NULL,
        [Unzip_Date] [datetime] NULL,
    PRIMARY KEY CLUSTERED 
    (
        [IncomingFileID] ASC
    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
    ) ON [PRIMARY]

    ALTER TABLE [Aging].[FTP_Incoming_Files] ADD  DEFAULT ((0)) FOR [Decrypted_File]
    ALTER TABLE [Aging].[FTP_Incoming_Files] ADD  DEFAULT (getdate()) FOR [Download_Date]
    ALTER TABLE [Aging].[FTP_Incoming_Files] ADD  DEFAULT ((0)) FOR [File_Record_Count]
    ALTER TABLE [Aging].[FTP_Incoming_Files] ADD  DEFAULT ((0)) FOR [Downloaded]
    ALTER TABLE [Aging].[FTP_Incoming_Files] ADD  DEFAULT (getdate()) FOR [DB_Create_Dt]
    ALTER TABLE [Aging].[FTP_Incoming_Files] ADD  DEFAULT (user_name()) FOR [DB_Create_User]
    ALTER TABLE [Aging].[FTP_Incoming_Files] ADD  DEFAULT ((0)) FOR [Email_Notif_Sent]
    ALTER TABLE [Aging].[FTP_Incoming_Files] ADD  DEFAULT ((0)) FOR [File_Moved]
    ALTER TABLE [Aging].[FTP_Incoming_Files] ADD  DEFAULT ((0)) FOR [SAS_Process_Complete]
    ALTER TABLE [Aging].[FTP_Incoming_Files] ADD  DEFAULT ((0)) FOR [WEXEU_Email_Sent]
    ALTER TABLE [Aging].[FTP_Incoming_Files] ADD  DEFAULT ((0)) FOR [FTP_Transmit_Success]
    ALTER TABLE [Aging].[FTP_Incoming_Files] ADD  DEFAULT ((0)) FOR [Unzip_Success]
    ALTER TABLE [Aging].[FTP_Incoming_Files]  WITH CHECK ADD FOREIGN KEY([FTPFileID])
    REFERENCES [Aging].[FTP_File_Inventory] ([FTPFileID])

    PRINT 'Table [Aging].[FTP_Incoming_Files] created successfully.';
END
ELSE
BEGIN
    PRINT 'Table [Aging].[FTP_Incoming_Files] already exists.';
END;
GO


