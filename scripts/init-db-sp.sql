USE [SRSVC]
GO 

/****** Object:  StoredProcedure [Expedia].[sp_py_Unpaid_Transactions]    Script Date: 7/2/2025 3:14:46 PM ******/

CREATE OR ALTER  PROCEDURE [Expedia].[sp_py_Unpaid_Transactions]

   @Program int

AS
SET NOCOUNT ON;

DECLARE
@Prev_Month date = cast(DATEADD(ss, -1, DATEADD(month, DATEDIFF(month, -1, getdate()) -1, 0)) as date);

select
rtrim(ltrim(r.TransID)) as TransID,
cast(bt.udf_2 as numeric(23,0)) as BookingID,
format (r.post_dt,'dd-MMM-yy') as Post_Dt,
r.Bill_Curr_Cd,
cast(r.Original_Bal as numeric(23,2)) as Original_Bal,
cast(r.Trans_Bal as numeric(23,2)) as Trans_Bal

from
srsvc.expedia.recon r
	inner join 
		(select
		 bt.transid,
		 bt.udf_2
		 from
		 srsvc.expedia.billed_transactions bt
		 where program = @Program
		 UNION ALL
		 select
		 ba.transid,
		 ba.udf_2
		 from
		 srsvc.expedia.billed_archive ba
         where program = @Program) bt
			on r.transid = bt.transid
	inner join srsvc.expedia.files f
		on r.bill_file_id = f.fileid
		and r.program = f.program

where
r.trans_bal <> 0
and r.program = @Program
AND ((r.ignore IS NULL) OR (r.ignore = 0))
AND f.billing_file_date <= @Prev_Month
AND year(r.post_dt) NOT IN (2011,2012);
GO

/****** Object:  StoredProcedure [Expedia].[sp_Unpaid_Transactions]    Script Date: 7/2/2025 3:14:46 PM ******/

CREATE OR ALTER  PROCEDURE [Expedia].[sp_Unpaid_Transactions]

   @Program int

AS
SET NOCOUNT ON;

DECLARE
@Prev_Month date = cast(DATEADD(ss, -1, DATEADD(month, DATEDIFF(month, -1, getdate()) -1, 0)) as date);

select
r.TransID,
bt.udf_2 as BookingID,
format (r.post_dt,'dd-MMM-yy') as Post_Dt,
r.Bill_Curr_Cd,
r.Original_Bal,
r.Trans_Bal

from
srsvc.expedia.recon r
	inner join 
		(select
		 bt.transid,
		 bt.udf_2
		 from
		 srsvc.expedia.billed_transactions bt
		 where program = @Program
		 UNION ALL
		 select
		 ba.transid,
		 ba.udf_2
		 from
		 srsvc.expedia.billed_archive ba
         where program = @Program) bt
			on r.transid = bt.transid
	inner join srsvc.expedia.files f
		on r.bill_file_id = f.fileid
		and r.program = f.program

where
r.trans_bal <> 0
and r.program = @Program
AND ((r.ignore IS NULL) OR (r.ignore = 0))
AND f.billing_file_date <= @Prev_Month
AND year(r.post_dt) NOT IN (2011,2012);
GO


/****** Object:  StoredProcedure [Expedia].[sp_Expedia_Audit_Processing]    Script Date: 7/2/2025 3:14:46 PM ******/

CREATE OR ALTER  PROCEDURE [Expedia].[sp_Expedia_Audit_Processing] as 

SET QUOTED_IDENTIFIER ON;


insert into SRSVC.Expedia.Recon_BIN_Dly_bal (BIN_ID, Program, Process_Date, Nbr_of_Crdts, Crdt_Bal_Outstanding,
											 Nbr_of_Dbts, Dbt_Bal_Outstanding, Ttl_Trans_Outstanding,
											 Ttl_Bal_Outstanding) 										 
select
bt.bin_id,
case when r.program is null then 488 else r.program end,
CAST(GETDATE() as DATE),
coalesce(case when SUM(case when r.trans_bal < 0 then 1 else 0 end) IS NULL then 0 else SUM(case when r.trans_bal < 0 then 1 else 0 end) END,0),
coalesce(case when SUM(case when r.trans_bal < 0 then r.trans_bal else 0 end) IS NULL then 0 else SUM(case when r.trans_bal < 0 then r.trans_bal else 0 end) END,0),
coalesce(case when SUM(case when r.trans_bal > 0 then 1 else 0 end) is null then 0 else SUM(case when r.trans_bal > 0 then 1 else 0 end) END,0),
coalesce(case when SUM(case when r.trans_bal > 0 then r.trans_bal end) is null then 0 else SUM(case when r.trans_bal > 0 then r.trans_bal end) END,0),
coalesce(case when COUNT(r.bin_id) IS NULL then 0 else COUNT(r.bin_id) END,0),
coalesce(case when SUM(r.trans_bal) IS NULL then 0 else SUM(r.Trans_bal) END,0)

from
srsvc.expedia.BIN_Table bt
	left outer join SRSVC.Expedia.Recon r
		on bt.BIN_ID = r.BIN_ID

where
((r.Ignore = 0) or (r.Ignore IS NULL))

group by 
bt.bin_id,r.program
                
order by 
bin_id asc,r.program asc;


with paymentrefno as
	(select
	 DISTINCT 
	 r.paymentrefnbr,
	 f.remit_currency_code,
	 f.fileid,
	 f.program
	 
	 from
	 srsvc.expedia.remit r
		inner join srsvc.expedia.files f
			on r.fileid = f.fileid
	       AND r.settlementcurrency = f.remit_Currency_Code
	       AND r.DB_Create_Dt >=DATEADD(d,-30,getdate())
		   and r.program = f.program)
update p

	set processed = 1,
		remitfileid = pend.fileid

from srsvc.expedia.pending_payments p
	inner join paymentrefno pend
		on p.paymentrefnbr = pend.paymentrefnbr
	   AND p.SettlementCurrency = pend.Remit_Currency_Code
	   and p.program = pend.program
where
p.Processed = 0;
	   
/* 20181212 - DWebber Change to update to use case statement if result is NULL */
update rbdb
	set TSYS_Balance = (select case when SUM(tbadb.balance) is null then 0 else SUM(tbadb.balance) end 
						from SRSVC.Expedia.TSYS_Bill_Acct_Dly_Bal tbadb 
						where tbadb.BIN_ID = rbdb.bin_id 
						AND tbadb.program = rbdb.program
						AND tbadb.TSYS_Date = CAST(GETDATE() as DATE))
	
from
SRSVC.Expedia.Recon_BIN_Dly_Bal rbdb

where
rbdb.DB_Create_Dt = CAST(GETDATE() as DATE);


update rbdb
	set Variance = rbdb.TSYS_Balance - rbdb.Ttl_Bal_Outstanding

from
SRSVC.Expedia.Recon_BIN_Dly_Bal rbdb

where
rbdb.DB_Create_Dt = CAST(GETDATE() as DATE);

GO

/****** Object:  StoredProcedure [Expedia].[sp_Expedia_Audit_Daily_Totals]    Script Date: 7/2/2025 3:14:46 PM ******/

CREATE OR ALTER  procedure [Expedia].[sp_Expedia_Audit_Daily_Totals]


@AuditDate date  = null

as
SET NOCOUNT ON;

IF @Auditdate IS NULL
BEGIN
set @AuditDate = cast(getdate() as date)
END;

WITH Audit_Balances as					
(select	
    bt.program,
	rb.Process_Date,				
	bt.Currency_Code,
	sum(t.balance) as TSYS_Balance,				
					
	CASE WHEN (select SUM(PaymentAmt) 				
			   from SRSVC.Expedia.Pending_Payments pp 		
			   where pp.SettlementCurrency = bt.Currency_Code 	
			   and pp.program = bt.program
			   AND pp.Processed = 0 		
			   AND pp.Posted_TSYS = 1
			   and pp.tsys_post_date < @Auditdate) IS NULL THEN 0		
	     ELSE (select SUM(PaymentAmt) 				
			   from SRSVC.Expedia.Pending_Payments pp 		
			   where pp.SettlementCurrency = bt.Currency_Code 
			   and pp.program = bt.program
			   AND pp.Processed = 0 AND pp.Posted_TSYS = 1
			   and pp.tsys_post_date < @Auditdate) END as Payments_TSYS_NotDB,		
			   		
	case when (select SUM(Bank_Fee) 				
	 from SRSVC.Expedia.Pending_Payments ppb 				
	 where ppb.SettlementCurrency = bt.Currency_Code 	
	 and ppb.program = bt.program
	 AND ppb.Posted_TSYS = 1 				
	 AND ppb.bank_fee_Chargeoff_Date IS NULL
	 and ppb.tsys_post_date < @Auditdate) is null then 0
	 else (select SUM(Bank_Fee) 				
	 from SRSVC.Expedia.Pending_Payments ppb 				
	 where ppb.SettlementCurrency = bt.Currency_Code 	
	 and ppb.program = bt.program
	 AND ppb.Posted_TSYS = 1 				
	 AND ppb.bank_fee_Chargeoff_Date IS NULL
	 and ppb.tsys_post_date < @Auditdate) end as Bank_Fees,				
	 				
	SUM(rb.ttl_Bal_Outstanding) as DB_Balance,				
					
	CASE WHEN (select SUM(PaymentAmt) 				
			   from SRSVC.Expedia.Pending_Payments pp1 		
			   where pp1.SettlementCurrency = bt.Currency_Code 	
			   and pp1.program = bt.program
			   AND pp1.Processed = 1 		
			   AND pp1.Posted_TSYS = 0) IS NULL THEN 0		
	     ELSE (select SUM(PaymentAmt) 				
			   from SRSVC.Expedia.Pending_Payments pp1 		
			   where pp1.SettlementCurrency = bt.Currency_Code 		
			   and pp1.program = bt.program
			   AND pp1.Processed = 1 		
			   AND pp1.Posted_TSYS = 0) END as Payments_DB_NotTSYS,		
	SUM(rb.Variance) as BIN_Variance				
					
from					
SRSVC.Expedia.Recon_BIN_Dly_Bal rb					
	inner join SRSVC.Expedia.BIN_Table bt				
		on bt.BIN_ID = rb.BIN_ID			
	 inner join 				
		(select			
		 t.BIN_ID,			
		 SUM(t.balance) as balance			
		 from			
		 SRSVC.Expedia.TSYS_Bill_Acct_Dly_Bal t			
		 where			
		 t.TSYS_Date = @Auditdate
		 group by			
		 t.BIN_ID) as t			
			on rb.BIN_ID = t.BIN_ID 		

where					
	rb.Process_Date =	@Auditdate
					
group by	
    bt.program,
	rb.Process_Date,				
	bt.Currency_Code)				
					
select					
*,					
CASE WHEN Payments_DB_NotTSYS IS NULL AND Payments_TSYS_NotDB IS NULL then (TSYS_Balance - Bank_Fees) - DB_Balance 					
	 WHEN Payments_DB_NotTSYS IS NULL AND Payments_TSYS_NotDB IS NOT NULL then (TSYS_Balance + Payments_TSYS_NotDB - Bank_Fees) - DB_Balance				
	 WHEN Payments_DB_NotTSYS IS NOT NULL AND Payments_TSYS_NotDB IS NULL then (TSYS_Balance - Bank_Fees) - (DB_Balance + Payments_DB_NotTSYS) 				
		 ELSE (TSYS_Balance + Payments_TSYS_NotDB - Bank_Fees) - (DB_Balance + Payments_DB_NotTSYS) END as Audit_Variance			
from					
Audit_Balances;	
GO

/****** Object:  StoredProcedure [Expedia].[sp_Expedia_Monthly_Aging_Update]    Script Date: 7/2/2025 3:14:46 PM ******/

CREATE OR ALTER  PROCEDURE [Expedia].[sp_Expedia_Monthly_Aging_Update] as 

update srsvc.expedia.recon
set Monthly_Age_Bucket = 'Ignore'

where
Ignore = 1
and Monthly_Age_Bucket <> 'Ignore';


update srsvc.expedia.recon
set Monthly_Age_Bucket = 
(case 
		when DATEDIFF(m,bill_month,GETDATE()) = 0 then 'Current Cycle'
		when DATEDIFF(m,bill_month,GETDATE()) = 1 then 'P00'
		when DATEDIFF(m,bill_month,GETDATE()) = 2 then 'P01'
		when DATEDIFF(m,bill_month,GETDATE()) = 3 then 'P02'
		when DATEDIFF(m,bill_month,GETDATE()) = 4 then 'P03'
		when DATEDIFF(m,bill_month,GETDATE()) = 5 then 'P04'
		when DATEDIFF(m,bill_month,GETDATE()) = 6 then 'P05'
		when DATEDIFF(m,bill_month,GETDATE()) = 7 then 'P06'
		when DATEDIFF(m,bill_month,GETDATE()) > 7 then 'P07'
		end)

where
Ignore = 0
AND Trans_Bal <> 0
;
GO

/****** Object:  StoredProcedure [Expedia].[sp_Expedia_Monthly_Aging_Update]    Script Date: 7/2/2025 3:14:46 PM ******/

CREATE OR ALTER  PROCEDURE [Expedia].[sp_Expedia_Monthly_Aging_Update] as 

update srsvc.expedia.recon
set Monthly_Age_Bucket = 'Ignore'

where
Ignore = 1
and Monthly_Age_Bucket <> 'Ignore';


update srsvc.expedia.recon
set Monthly_Age_Bucket = 
(case 
		when DATEDIFF(m,bill_month,GETDATE()) = 0 then 'Current Cycle'
		when DATEDIFF(m,bill_month,GETDATE()) = 1 then 'P00'
		when DATEDIFF(m,bill_month,GETDATE()) = 2 then 'P01'
		when DATEDIFF(m,bill_month,GETDATE()) = 3 then 'P02'
		when DATEDIFF(m,bill_month,GETDATE()) = 4 then 'P03'
		when DATEDIFF(m,bill_month,GETDATE()) = 5 then 'P04'
		when DATEDIFF(m,bill_month,GETDATE()) = 6 then 'P05'
		when DATEDIFF(m,bill_month,GETDATE()) = 7 then 'P06'
		when DATEDIFF(m,bill_month,GETDATE()) > 7 then 'P07'
		end)

where
Ignore = 0
AND Trans_Bal <> 0
;
GO

/****** Object:  StoredProcedure [Expedia].[sp_DEV_Aging_Buckets]    Script Date: 7/2/2025 3:14:46 PM ******/

CREATE OR ALTER  PROCEDURE [Expedia].[sp_DEV_Aging_Buckets]

   @Program int

AS
SET NOCOUNT ON;

select
case
	when Daily_Age_Bucket IS NULL then 'Day_00-04'
	when Daily_Age_Bucket <5 then 'Day_00-04'
	when Daily_Age_Bucket BETWEEN 5 AND 10 then 'Day_05-10'
	when Daily_Age_Bucket BETWEEN 11 AND 15 then 'Day_11-15'
	when Daily_Age_Bucket BETWEEN 16 AND 20 then 'Day_16-20'
	when Daily_Age_Bucket BETWEEN 21 AND 25 then 'Day_21-25'
	when Daily_Age_Bucket BETWEEN 26 AND 30 then 'Day_26-30'
	when Daily_Age_Bucket >30 then 'Greater_Than_30' end as Age_Bucket,
Bill_Curr_Cd,
count(r.reconid) as Total_Trans_Outstanding,
cast(sum(r.Trans_Bal) as numeric(18,2)) as Total_Trans_Amount_Outstanding,
cast(sum(round(r.Trans_Bal/cr.Sell_Curr_Conv_Rt,2)) as numeric(18,2)) as Total_Trans_Outstanding_USD

from
srsvc.expedia.recon r
	inner join srsvc.aging.bin_map bm
		on r.bin = bm.bin
	inner join srsvc.aging.curr_rates cr	
		on bm.MC_Curr_Cd = cr.Source_Curr_Cd
	   AND cr.Reference_Curr_Cd = '840'
	   AND cr.srsvc_current_flg = 'Y'

where
r.Trans_Bal <> 0
and r.program = @Program
AND ((r.Ignore IS NULL) OR (r.Ignore = 0))
AND year(r.post_dt) NOT IN (2011,2012)
group by
case
	when Daily_Age_Bucket IS NULL then 'Day_00-04'
	when Daily_Age_Bucket <5 then 'Day_00-04'
	when Daily_Age_Bucket BETWEEN 5 AND 10 then 'Day_05-10'
	when Daily_Age_Bucket BETWEEN 11 AND 15 then 'Day_11-15'
	when Daily_Age_Bucket BETWEEN 16 AND 20 then 'Day_16-20'
	when Daily_Age_Bucket BETWEEN 21 AND 25 then 'Day_21-25'
	when Daily_Age_Bucket BETWEEN 26 AND 30 then 'Day_26-30'
	when Daily_Age_Bucket >30 then 'Greater_Than_30' end ,
Bill_Curr_Cd

order by
Age_Bucket
GO

/****** Object:  StoredProcedure [Expedia].[sp_Daily_Aging_Update]    Script Date: 7/2/2025 3:14:46 PM ******/

CREATE OR ALTER  PROCEDURE [Expedia].[sp_Daily_Aging_Update] as 

update srsvc.expedia.recon
set DSO = NULL,
    Paid_dt = NULL,
    Monthly_Age_Bucket = NULL

where
monthly_age_bucket = 'Paid'
AND Ignore = 0
AND Trans_Bal <> 0;

update srsvc.expedia.recon
set Daily_Age_Bucket = 
DATEDIFF(d,Post_Dt,GETDATE())

where
Monthly_Age_Bucket <> 'Paid'
AND Ignore = 0;


update srsvc.expedia.recon
set DSO =
DATEDIFF(d,post_dt,paid_dt)

where
monthly_age_bucket = 'Paid'
AND Ignore = 0
AND DSO IS NULL;


delete from
srsvc.expedia.Aging_Daily;

insert into srsvc.expedia.Aging_Daily
(
Billed_Currency,
Program,
D1_D5,
D6_D10,
D11_D15,
D16_D20,
D21_D25,
D25_D30,
D30_Plus)

select
Bill_Curr_Cd,
Program,
SUM(case when daily_age_bucket BETWEEN 1 AND 5  then trans_bal else 0 end),
SUM(case when daily_age_bucket BETWEEN 6 AND 10  then trans_bal else 0 end),
SUM(case when daily_age_bucket BETWEEN 11 AND 15  then trans_bal else 0 end),
SUM(case when daily_age_bucket BETWEEN 16 AND 20  then trans_bal else 0 end),
SUM(case when daily_age_bucket BETWEEN 21 AND 25  then trans_bal else 0 end),
SUM(case when daily_age_bucket BETWEEN 26 AND 30  then trans_bal else 0 end),
SUM(case when daily_age_bucket >30  then trans_bal else 0 end)

from
srsvc.expedia.Recon

where
monthly_age_bucket <> 'Paid'
AND Ignore = 0


group by
Bill_Curr_Cd,
Program;

update srsvc.expedia.recon
set Monthly_Age_Bucket = 
(case 
		when DATEDIFF(m,bill_month,GETDATE()) = 0 then 'Current Cycle'
		when DATEDIFF(m,bill_month,GETDATE()) = 1 then 'P00'
		when DATEDIFF(m,bill_month,GETDATE()) = 2 then 'P01'
		when DATEDIFF(m,bill_month,GETDATE()) = 3 then 'P02'
		when DATEDIFF(m,bill_month,GETDATE()) = 4 then 'P03'
		when DATEDIFF(m,bill_month,GETDATE()) = 5 then 'P04'
		when DATEDIFF(m,bill_month,GETDATE()) = 6 then 'P05'
		when DATEDIFF(m,bill_month,GETDATE()) = 7 then 'P06'
		when DATEDIFF(m,bill_month,GETDATE()) > 7 then 'P07'
		end)

where
Ignore = 0
AND Trans_Bal <> 0
AND Monthly_Age_Bucket IS NULL;
select
remit.*

from
srsvc.expedia.REMIT

where
((Pymnt_Applied = 0)
OR (Pymnt_Applied IS NULL))
AND TransID IN (select TransID from srsvc.expedia.Recon where ((Ignore = 1) or (Freeze = 1)));

GO

/****** Object:  StoredProcedure [Expedia].[sp_Billing_File_Recon_Load]    Script Date: 7/2/2025 3:14:46 PM ******/

CREATE OR ALTER  PROCEDURE [Expedia].[sp_Billing_File_Recon_Load] as 

SET QUOTED_IDENTIFIER ON;
insert into srsvc.Expedia.BIN_Table (BIN)

select
DISTINCT
SUBSTRING(CCN,1,6)
from
SRSVC.Expedia.Billed_Transactions
where
Trans_Type NOT IN ('H','Z')
AND ((Processed IS NULL) or (Processed = 0))
AND SUBSTRING(CCN,1,6) NOT IN (select BIN from SRSVC.Expedia.BIN_Table);


insert into srsvc.expedia.Recon
	(TransID,Post_Dt,Bill_Curr_Cd,Original_Bal,nbr_of_b,sum_of_b,nbr_of_c,sum_of_c,
	 nbr_of_d,sum_of_d,nbr_of_r,sum_of_r,Trans_Bal,Freeze,BIN,bill_month,Monthly_Age_Bucket,Ignore,bill_file_id,BIN_ID,Program)
select
bt.TransID,
bt.Posting_Dt,
bt.Bill_Curr_Cd,
bt.Bill_Amt,
0,
0.00,
0,
0.00,
0,
0.00,
0,
0.00,
bt.Bill_Amt,
0,
SUBSTRING(bt.CCN,1,6),
convert(char(10), DATEADD(s,-1, DATEADD(mm, DATEDIFF(m,0,Posting_Dt)+1,0)),101),
'Current Cycle',
0,
FileID,
bin.bin_id,
bt.Program


from srsvc.expedia.Billed_Transactions bt
	inner join SRSVC.Expedia.bin_table bin
		on SUBSTRING(bt.CCN,1,6) = bin.bin
		and bt.program = bin.program
		
where bt.Trans_Type NOT IN ('H','Z')
AND ((bt.Processed IS NULL) or (bt.Processed = 0));

update srsvc.expedia.Billed_Transactions 
set Comments = 'Duplicate Transaction'
where TransID LIKE '%-DUP'
AND Processed = 0
AND DB_Create_Dt = convert(date, GETDATE());

update bt
set bt.processed = 1
from srsvc.expedia.Billed_Transactions bt
	inner join srsvc.expedia.recon r
		on r.TransID = bt.TransID
		and r.Program = bt.program
where ((bt.Processed IS NULL) or (bt.Processed = 0));

update srsvc.expedia.Recon
set Ignore = 1,
	Freeze = 1
where
TransID LIKE '%-DUP'
AND Ignore = 0
;
/*
ALTER INDEX PLOG ON srsvc.expedia.billed_transactions
REBUILD;
GO

ALTER INDEX Processed ON srsvc.expedia.billed_transactions
REBUILD;
GO
*/
GO

/****** Object:  StoredProcedure [Expedia].[sp_Aging_Buckets]    Script Date: 7/2/2025 3:14:46 PM ******/

CREATE OR ALTER  PROCEDURE [Expedia].[sp_Aging_Buckets]

   @Program int

AS
SET NOCOUNT ON;

select
case
	when Daily_Age_Bucket IS NULL then 'Day_00-04'
	when Daily_Age_Bucket <5 then 'Day_00-04'
	when Daily_Age_Bucket BETWEEN 5 AND 10 then 'Day_05-10'
	when Daily_Age_Bucket BETWEEN 11 AND 15 then 'Day_11-15'
	when Daily_Age_Bucket BETWEEN 16 AND 20 then 'Day_16-20'
	when Daily_Age_Bucket BETWEEN 21 AND 25 then 'Day_21-25'
	when Daily_Age_Bucket BETWEEN 26 AND 30 then 'Day_26-30'
	when Daily_Age_Bucket >30 then 'Greater_Than_30' end as Age_Bucket,
Bill_Curr_Cd,
count(r.reconid) as Total_Trans_Outstanding,
sum(r.Trans_Bal) as Total_Trans_Amount_Outstanding,
cast(sum(round(r.Trans_Bal/cr.Sell_Curr_Conv_Rt,2)) as decimal(18,2)) as Total_Trans_Outstanding_USD

from
srsvc.expedia.recon r
	inner join srsvc.aging.bin_map bm
		on r.bin = bm.bin
	inner join srsvc.aging.curr_rates cr	
		on bm.MC_Curr_Cd = cr.Source_Curr_Cd
	   AND cr.Reference_Curr_Cd = '840'
	   AND cr.srsvc_current_flg = 'Y'

where
r.Trans_Bal <> 0
and r.program = @Program
AND ((r.Ignore IS NULL) OR (r.Ignore = 0))
AND year(r.post_dt) NOT IN (2011,2012)
group by
case
	when Daily_Age_Bucket IS NULL then 'Day_00-04'
	when Daily_Age_Bucket <5 then 'Day_00-04'
	when Daily_Age_Bucket BETWEEN 5 AND 10 then 'Day_05-10'
	when Daily_Age_Bucket BETWEEN 11 AND 15 then 'Day_11-15'
	when Daily_Age_Bucket BETWEEN 16 AND 20 then 'Day_16-20'
	when Daily_Age_Bucket BETWEEN 21 AND 25 then 'Day_21-25'
	when Daily_Age_Bucket BETWEEN 26 AND 30 then 'Day_26-30'
	when Daily_Age_Bucket >30 then 'Greater_Than_30' end ,
Bill_Curr_Cd

order by
Age_Bucket
GO

/****** Object:  StoredProcedure [Expedia].[sp_Billing_File_Overview]    Script Date: 7/2/2025 3:14:46 PM ******/

CREATE OR ALTER  PROCEDURE [Expedia].[sp_Billing_File_Overview] as 


delete from srsvc.expedia.Billing_File_Overview;


insert into srsvc.expedia.Billing_File_Overview
(bill_file_nm,
Program,
nbr_of_billed_trans,
ttl_billed_amt,
ttl_trans_settled,
ttl_amt_settled,
nbr_of_b_items,
ttl_b_items,
nbr_of_c_items,
ttl_c_items,
nbr_of_d_items,
ttl_d_items,
nbr_of_r_items,
ttl_r_items,
ttl_remit_items_applied,
ttl_trans_outstanding,
ttl_bal_outstanding)

select
f.file_nm,
f.Program,
count(recon.transid),
sum(recon.Original_Bal),
sum(case when recon.trans_bal = 0 then 1 else 0 end),
sum(case when recon.trans_bal = 0 then recon.original_bal else 0 end),
sum(recon.nbr_of_b),
sum(recon.sum_of_b),
sum(recon.nbr_of_c),
sum(recon.sum_of_c),
sum(recon.nbr_of_d),
sum(recon.sum_of_d),
sum(recon.nbr_of_r),
sum(recon.sum_of_r) ,
sum(recon.nbr_of_b)+sum(nbr_of_c)+sum(nbr_of_d)+sum(nbr_of_r),
sum(case when recon.trans_bal <> 0 then 1 else 0 end),
sum(recon.trans_bal)



from
srsvc.expedia.Recon recon
	inner join srsvc.expedia.Files f
		on recon.bill_File_ID = f.FileID

where
recon.Ignore = 0


group by
f.File_Nm,
f.Program

order by
f.File_Nm;

GO
