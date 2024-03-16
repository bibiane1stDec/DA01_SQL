------1-Thống kê tổng số lượng người mua và số lượng đơn hàng đã hoàn thành mỗi tháng ( Từ 1/2019-4/2022)
select 
      FORMAT_DATE('%Y-%m', DATE (created_at)) as month_year,
count(distinct order_id) as noid,
count(distinct user_id) as nouser
from bigquery-public-data.thelook_ecommerce.orders
      WHERE FORMAT_DATE('%Y-%m', DATE (created_at)) BETWEEN '2019-01' AND '2022-04'
      AND status ='Complete'
 group by 1
      order by month_year 
-----2-Giá trị đơn hàng trung bình (AOV) và số lượng khách hàng mỗi tháng
 select 
 FORMAT_DATE('%Y-%m', DATE (created_at)) as month_year,
 COUNT(distinct user_id) as distinct_users, 
ROUND(AVG(sale_price),2) as average_order_value 
from bigquery-public-data.thelook_ecommerce.order_items
where  FORMAT_DATE('%Y-%m',created_at) between '2019-01' and '2022-04' 
 group by 1
      order by month_year
-----3-------------
with young_old as (
SELECT u.first_name, u.last_name, u.gender, u.age,
 case when u.age = y.youngest then 'youngest' else null end as tag
 from (
 select gender, min(age) as youngest from bigquery-public-data.thelook_ecommerce.users group by gender) as y 
 join bigquery-public-data.thelook_ecommerce.users as u 
 on  y.youngest= u.age
 where created_at between '2019-01-01' and '2022-05-01'
union distinct
SELECT u.first_name, u.last_name, u.gender, u.age,
 case when u.age = o.oldest then 'oldest' else null end as tag
 from (
 select gender, max(age) as oldest from bigquery-public-data.thelook_ecommerce.users group by gender) as o 
 join bigquery-public-data.thelook_ecommerce.users as u 
 on  o.oldest= u.age
 where created_at between '2019-01-01' and '2022-05-01')

 SELECT 
 gender, age, tag, COUNT(*)
 from young_old
 group by gender, age, tag
----4--------

---c2-------------------------
 with cte as (
  select
FORMAT_DATE('%Y-%m', DATE (a.created_at)) as month_year,
a.product_id,b.name as product_name,
sum(a.sale_price) as sales,
sum(b.cost) as cost,
sum(a.sale_price)-sum(b.cost) as profit,
from bigquery-public-data.thelook_ecommerce.order_items as a join bigquery-public-data.thelook_ecommerce.products as b
on a.product_id = b.id
where DATE(created_at) BETWEEN '2019-01-01' AND '2022-04-30'
group by 1,2,3)
-- xếp hạng 
select * from 
(select month_year, product_id, product_name, sales, cost, profit,
dense_rank() over(partition by month_year order by profit desc) as rank_per_month from cte
order by month_year
  ) as t 
  where rank_per_month <=5


----5--------
with cte as (select 
format_date('%y-%m-%d',a.created_at) as date, 
 b.category as product_category,
sum(a.sale_price) as revenue
from  bigquery-public-data.thelook_ecommerce.order_items as a 
left join bigquery-public-data.thelook_ecommerce.products as b
on a.id = b.id
 group by format_date('%y-%m-%d',a.created_at), b.category
 order by 1
)
 select * from cte
 where date between '2022-01-15' and '2022-04-15'
 order by product_category, date
----III.1------------------------
with no_null as (select month_year,  product_category,tpv,
 (tpv - lag(tpv) over (partition by product_category order by month_year))/lag(tpv) over (partition by product_category order by month_year) as revenue_growth
, tpo,
(tpo - lag(tpo) over (partition by product_category order by month_year))/lag(tpo) over (partition by product_category order by month_year) as Order_growth,
tc, tpv-tc as total_profit,
(tpv-tc)/tc as Profit_to_cost_ratio
 from
 (select 
format_date('%y-%m',a.created_at) as month_year,
c.category as product_category,
round(count(b.order_id) over(partition by format_date('%y-%m',a.created_at)),2) as tpo,
round(sum(b.sale_price) over(partition by format_date('%y-%m',a.created_at)),2) as tpv,
round(sum(c.cost) over(partition by format_date('%y-%m',a.created_at)),2) as TC
FROM bigquery-public-data.thelook_ecommerce.orders AS A 
  INNER JOIN bigquery-public-data.thelook_ecommerce.order_items AS B 
    ON A.order_id = B.order_id
  INNER JOIN bigquery-public-data.thelook_ecommerce.products as c 
    on b.id=c.id)
where product_category is not null
 and tpv >0 and tpo > 0 and tc > 0),
---- cohort ----
CREATE VIEW bigquery-public-data.thelook_ecommerce.vw_ecommerce_analyst AS
-- Calculate Total order, total revenue, total profit and total cost
WITH cte1 AS (
SELECT
FORMAT_DATE('%Y-%m', DATE (a.created_at)) AS month_year, EXTRACT (YEAR FROM a.created_at) AS year,
c.category AS product_category, (SUM (b.sale_price) - SUM (c.cost)) AS TPV,
COUNT (a.order_id) AS TPO, SUM (c.cost) AS total_cost,
((SUM (b.sale_price) - SUM (c.cost)) - SUM (c.cost)) AS total_profit
FROM bigquery-public-data.thelook_ecommerce.orders AS a 
JOIN bigquery-public-data.thelook_ecommerce.order_items AS b
ON a.order_id=b.order_id
JOIN bigquery-public-data.thelook_ecommerce.products AS c
ON b.product_id=c.id
GROUP BY FORMAT_DATE('%Y-%m', DATE (a.created_at)), c.category, EXTRACT (YEAR FROM a.created_at))

-- CREATE view table with revenue growth, order growth, profit to cost ratio
SELECT month_year, year, product_category, TPV, TPO,
100*(TPV - LAG (TPV) OVER (PARTITION BY product_category ORDER BY month_year ASC))/(TPV + LAG (TPV) OVER (PARTITION BY product_category ORDER BY month_year ASC)) ||'%' AS revenue_growth,
100*(TPO - LAG (TPO) OVER (PARTITION BY product_category ORDER BY month_year ASC))/(TPO + LAG (TPO) OVER (PARTITION BY product_category ORDER BY month_year ASC)) ||'%' AS order_growth,
total_cost, 
total_profit, total_profit/cte1.total_cost AS profit_to_cost_ratio
FROM cte1

--COHORT ANALYSIS

WITH cte AS 
 (
 SELECT user_id,sale_price,
  FORMAT_DATE('%Y-%m', DATE (first_puchase_date)) as cohort_date,
  created_at,
  (extract(year from created_at)-extract(year from first_puchase_date))*12 
  + (extract(month from created_at)-extract(month from first_puchase_date))+ 1 as index
 FROM 
 (
 SELECT user_id,sale_price,
  MIN(created_at) OVER (PARTITION BY user_id) as first_puchase_date,
 created_at
 FROM bigquery-public-data.thelook_ecommerce.order_items
 WHERE status ='Complete'
)
 )

 ,cte2 as (
 SELECT cohort_date, index,
  COUNT(DISTINCT user_id) as cnt,
  SUM (sale_price) as revenue
 FROM cte
 WHERE index <=4
 GROUp BY 1,2
 ORDER BY cohort_date)

,customer_cohort AS (
 SELECT cohort_date,
 SUM(case when index = 1 then cnt else 0 end) as t1,
 SUM(case when index = 2 then cnt else 0 end) as t2,
 SUM(case when index = 3 then cnt else 0 end) as t3,
 SUM(case when index = 4 then cnt else 0 end) as t4
 FROM cte2
 GROUP BY cohort_date
 ORDER BY cohort_date
)

--retention cohort
, retention_cohort AS (
SELECT cohort_date,
ROUND(100.00* t1/t1,2)||'%' t1,
ROUND(100.00* t2/t1,2)||'%' t2,
ROUND(100.00* t3/t1,2)||'%' t3,
ROUND(100.00* t4/t1,2)||'%' t4
FROM customer_cohort)

--churn cohort
SELECT cohort_date,
(100-ROUND(100.00* t1/t1,2))||'%' t1,
(100-ROUND(100.00* t2/t1,2))||'%' t2,
(100-ROUND(100.00* t3/t1,2))||'%' t3,
(100-ROUND(100.00* t4/t1,2))||'%' t4
FROM customer_cohort

