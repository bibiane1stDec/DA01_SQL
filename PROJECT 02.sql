------1-----------------------
select 
concat (extract(year from created_at),'-', extract(month from created_at)) as month_year,
count(distinct order_id) as noid,
count(distinct user_id) as nouser
 from bigquery-public-data.thelook_ecommerce.orders
 group by concat (extract(year from created_at),'-', extract(month from created_at))

-----2-------------
 select distinct user_id as distinct_users,
 FORMAT_DATE('%Y-%m',created_at) as month_year,  
 sum(sale_price) over (order by extract(month from created_at) )/ count(*) over(order by extract(month from created_at)) as average
from bigquery-public-data.thelook_ecommerce.order_items
where  FORMAT_DATE('%Y-%m',created_at) between '2019-01' and '2022-04' 

----em dùng lệnh 'avg(sale_price) over (partition by extract(month from created_at) )' thay cho câu sum được ko ạ
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

 select  gender, 
 sum(case when tag = 'youngest' then 1 else 0 end) as youngest,
 sum(case when tag = 'oldest' then 1 else 0 end) as oldest
 from young_old
 group by gender
----4--------
select * from (
SELECT month_year, product_id, product_name, sales, cost, profit,
  DENSE_RANK() OVER (PARTITION BY month_year ORDER BY profit DESC) AS rank_per_month
FROM (SELECT 
  format_date('%y-%m',a.created_at) as month_year,
   c.id as product_id, c.name as product_name,
   count(c.id) over(partition by b.order_id) as quantity,
   c.cost*count(c.id) over(partition by b.order_id) as cost,
   c.retail_price*count(c.id) over(partition by b.order_id) as sales,
   (c.retail_price-c.cost)*count(c.id) over(partition by b.order_id) as profit
  FROM bigquery-public-data.thelook_ecommerce.orders AS A 
  INNER JOIN bigquery-public-data.thelook_ecommerce.order_items AS B 
    ON A.order_id = B.order_id
  INNER JOIN bigquery-public-data.thelook_ecommerce.products as c 
    on b.id=c.id
     WHERE a.created_at BETWEEN '2019-01-01' AND '2022-04-30' 
order by month_year asc, profit desc) as monthlysales ) as a
 where rank_per_month <=5

----5--------
with cte as (select 
format_date('%y-%m-%d',a.created_at) as date, b.category as product_category,
sum(a.sale_price) as revenue
from  bigquery-public-data.thelook_ecommerce.order_items as a 
left join bigquery-public-data.thelook_ecommerce.products as b
on a.id = b.id
 group by format_date('%y-%m-%d',a.created_at), b.category
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

no_dup as ( select * from
 (select n.*,
 row_number() over (partition by product_category order by month_year) as dup_flag
 from no_null as n) as d
 where dup_flag = 1),

index as ( 
 select product_category, 
 total_profit,
 format_date('%y-%m', first_date) as cohort_date,
 month_year , 
(extract (year from month_year)-extract (year from first_date))*12 
 +
(extract (month from month_year)-extract (month from first_date))+1 as index 
 from 
 (Select product_category, total_profit, min(month_year) over (partition by product_category) as first_date,
 month_year 
 from no_dup )),

xxx as (
 select cohort_date, index,
 count (distinct product_category) as cnt,
 sum(total_profit) as profit
 from index 
 group by cohort_date, index),
 
pf_cohort as (
 select cohort_date,
 sum(case when index = 1 then cnt else 0) end as m1,
  sum(case when index = 2 then cnt else 0) end as m2,
  sum(case when index = 3 then cnt else 0) end as m3,
  sum(case when index = 4 then cnt else 0) end as m4,
 from xxx
 group by cohort_date 
 order by cohort_date)

 select 
 cohort_date,
(100-round(100.00* m1/m1,2))||'%' as m1,
(100-round(100.00* m2/m1,2))|| '%' as m2,
(100-round(100.00* m3/m1,2)) || '%' as m3,
(100-round(100.00* m4/m1,2)) || '%' as m4
 from pf cohort

 
 
----III.2------------------------























