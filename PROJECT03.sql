
--- ex 1 -------------------
select 
PRODUCTLINE, YEAR_ID, DEALSIZE,
SUM (SALES) AS REVENUE
from public.sales_dataset_rfm_prj_clean
GROUP BY PRODUCTLINE, YEAR_ID, DEALSIZE
order by productline
---- EX 2- tháng có bán tốt nhất mỗi năm
SELECT 
month_id||'-'||year_id as month_year,
max(SUM (SALES)) over (partition by month_id||'-'||year_id)  AS REVENUE, 
count(ordernumber)
FROM public.sales_dataset_rfm_prj_clean
group by month_id||'-'||year_id
order by month_id||'-'||year_id

-----ex 3- Product line nào được bán nhiều ở tháng 11?

	select
	month_id||'-'||year_id as month_year, productline, 
	sum(sales),
count(ordernumber) 
FROM public.sales_dataset_rfm_prj_clean
where month_id= '11'
group by month_id||'-'||year_id, productline
order by month_id||'-'||year_id

--- ex 4 --- Đâu là sản phẩm có doanh thu tốt nhất ở UK mỗi năm? 
select year_id, productline, revenue, rank
 from (
select year_id, productline, 
sum(sales) as revenue,
	 row_number() over(partition by year_id) as rank
FROM public.sales_dataset_rfm_prj_clean
where country = 'UK'
group by year_id, productline
order by year_id) as a

----ex.45 Ai là khách hàng tốt nhất, phân tích dựa vào RFM. ((sử dụng lại bảng customer_segment ở buổi học 23)
---customer_segment 555

with rfm_cust as (
select customername,
current_date - max(orderdate) as R,
count(distinct ordernumber) as F,
sum(sales) as M
from public.sales_dataset_rfm_prj_clean
group by customername),

rfm_score as( ---chia các giá trị thành các khoảng trên thang điểm 1-5*/
select customername,
ntile(5) over(order by R desc) as R_score,
ntile(5) over(order by F desc) as F_score,
ntile(5) over(order by M desc) as M_score
from rfm_cust)
,
--phân nhóm theo 124 tổ hợp RFM */
rfm_final as (select customername,
cast(r_score as varchar) ||cast(f_score as varchar)||cast(m_score as varchar) as rfm_score
from rfm_score)
	 
select customername,
	 count(*) from (
	select a. customername, b.segment 
	 from
rfm_final as a
		 join segment_score b on a.rfm_score= b.scores) as a
		 where segment = 'Champions'
		 group by customername
	 order by count(*)



select * from public.sales_dataset_rfm_prj_clean
select * from segment_score



















