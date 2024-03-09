create table SALES_DATASET_RFM_PRJ
(
  ordernumber VARCHAR,
  quantityordered VARCHAR,
  priceeach        VARCHAR,
  orderlinenumber  VARCHAR,
  sales            VARCHAR,
  orderdate        VARCHAR,
  status           VARCHAR,
  productline      VARCHAR,
  msrp             VARCHAR,
  productcode      VARCHAR,
  customername     VARCHAR,
  phone            VARCHAR,
  addressline1     VARCHAR,
  addressline2     VARCHAR,
  city             VARCHAR,
  state            VARCHAR,
  postalcode       VARCHAR,
  country          VARCHAR,
  territory        VARCHAR,
  contactfullname  VARCHAR,
  dealsize         VARCHAR
) 

select * from public.sales_dataset_rfm_prj

--------------EX. 01-------------------------------------------------
alter table sales_dataset_rfm_prj
alter column ordernumber type numeric using (trim(ordernumber) :: numeric)

alter table sales_dataset_rfm_prj
alter column quantityordered type numeric using (trim(quantityordered) :: numeric)

alter table sales_dataset_rfm_prj
alter column priceeach type numeric using (trim(priceeach) :: numeric)

alter table sales_dataset_rfm_prj
alter column orderlinenumber type int using (trim(orderlinenumber) :: int)

alter table sales_dataset_rfm_prj
alter column sales type decimal using (trim(sales) :: decimal)

SET datestyle = 'iso,mdy';  
ALTER TABLE sales_dataset_rfm_prj
ALTER COLUMN orderdate TYPE date USING (TRIM(orderdate):: date)

alter table sales_dataset_rfm_prj
alter column status type varchar(10) using (trim(status) :: varchar(10))

alter table sales_dataset_rfm_prj
alter column status type varchar(10) using (trim(status) :: varchar(10))

alter table sales_dataset_rfm_prj
alter column productline type varchar(20) using (trim(productline) :: varchar(20))

alter table sales_dataset_rfm_prj
alter column msrp type int using (trim(msrp) :: int)

alter table sales_dataset_rfm_prj
alter column productcode type varchar(20) using (trim(productcode) :: varchar(20))

alter table sales_dataset_rfm_prj
alter column phone type int using (trim(productline) :: int )
------------------------------------------------------------
--------------EX. 02-------------------------------------------------
--- EM LỠ ĐỔI TÊN BẢNG RỒI MỚI LÀM BÀI NÀY Ạ
SELECT ORDERNUMBER, QUANTITYORDERED, 
PRICEEACH, ORDERLINENUMBER, 
SALES, ORDERDATE
FROM SALES_DATASET_RFM_PRJ_CLEAN
WHERE (ORDERNUMBER, QUANTITYORDERED, 
PRICEEACH, ORDERLINENUMBER, 
SALES, ORDERDATE) IS NULL
--------------EX. 03-------------------------------------------------
alter table sales_dataset_rfm_prj
add column CONTACTLASTNAME varchar(20)

alter table sales_dataset_rfm_prj
add column CONTACTFIRSTNAME varchar(20)

UPDATE sales_dataset_rfm_prj
SET CONTACTFIRSTNAME = SUBSTRING(CONTACTFULLNAME FROM 1 FOR (POSITION('-' IN CONTACTFULLNAME)-1)) 

UPDATE sales_dataset_rfm_prj
SET CONTACTLASTNAME = SUBSTRING(CONTACTFULLNAME FROM (POSITION('-' IN CONTACTFULLNAME)+1) FOR (length(CONTACTFULLNAME)-POSITION('-' IN CONTACTFULLNAME))) 

UPDATE sales_dataset_rfm_prj
SET CONTACTLASTNAME = Upper(left(CONTACTLASTNAME,1))||right(CONTACTLASTNAME,length(CONTACTLASTNAME)-1)

UPDATE sales_dataset_rfm_prj
SET CONTACTFIRSTNAME = Upper(left(CONTACTFIRSTNAME,1))||right(CONTACTFIRSTNAME,length(CONTACTFIRSTNAME)-1)

----------------------------------------------------------------------------------------------------
--------------EX. 04-------------------------------------------------
alter table sales_dataset_rfm_prj
add column QTR_ID VARCHAR;

alter table sales_dataset_rfm_prj
add column MONTH_ID INT;

alter table sales_dataset_rfm_prj
add column YEAR_ID INT; 

UPDATE sales_dataset_rfm_prj
SET MONTH_ID = EXTRACT (MONTH FROM ORDERDATE)

UPDATE sales_dataset_rfm_prj
SET YEAR_ID = EXTRACT (YEAR FROM ORDERDATE)

UPDATE sales_dataset_rfm_prj
SET QTR_ID = 
CASE 
	WHEN MONTH_ID IN (1,2,3) THEN 'I'
	WHEN MONTH_ID IN (4,5,6) THEN 'II'
	WHEN MONTH_ID IN (7,8,9) THEN 'I'
	ELSE 'IV'
	END 

SELECT * FROM sales_dataset_rfm_prj
----------------------------------------------------------------------------------------------------
--------------EX. 05-------------------------------------------------
---BOXPLOT------------
WITH MIN_MAX AS (
SELECT 
Q1-1.5*IQR as min,
Q3+1.5*IQR as max 
FROM (
SELECT 
PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY QUANTITYORDERED) AS Q1,
PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY QUANTITYORDERED) AS Q3,
PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY QUANTITYORDERED) 
- 
PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY QUANTITYORDERED) AS IQR
FROM sales_dataset_rfm_prj) AS A ) 
SELECT * FROM sales_dataset_rfm_prj
WHERE QUANTITYORDERED < (SELECT MIN FROM MIN_MAX)
OR QUANTITYORDERED > (SELECT MIN FROM MIN_MAX)
---z-SCORE------------------------------------
-- Z = ( QUANTITYORDERED - MEAN )/STDDEV
WITH CTE AS (
SELECT QUANTITYORDERED, 
AVG(QUANTITYORDERED) AS AVG,
STDDEV(QUANTITYORDERED) AS SD
FROM  sales_dataset_rfm_prj
),
OUTLIER AS (
SELECT QUANTITYORDER,
(QUANTITYORDER-AVG)/SD AS Z-SCORE 
FROM CTE
WHERE ABS((QUANTITYORDER-AVG)/SD) > 3)
)
UPDATE sales_dataset_rfm_prj 
SET QUANTITYORDER = (SELECT AVG(QUANTITYORDER) FROM sales_dataset_rfm_prj
					WHERE QUANTITYORDER IN (SELECT QUANTITYORDER FROM OUTLIER) )

SELECT * FROM sales_dataset_rfm_prj

----EX.06-------- 
ALTER TABLE sales_dataset_rfm_prj
RENAME TO SALES_DATASET_RFM_PRJ_CLEAN

















