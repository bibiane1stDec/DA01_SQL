select 
concat (extract(year from created_at),'-', extract(month from created_at)) as month_year,
count(distinct order_id) as noid,
count(distinct user_id) as nouser
 from bigquery-public-data.thelook_ecommerce.orders
 group by concat (extract(year from created_at),'-', extract(month from created_at))

-----2-------------
select 
FORMAT_DATE('%Y-%m',created_at),
 user_id as distinct_users,
 sum(sale_price) over (partition by extract(month from created_at) )/ count(*) over(partition by extract(month from created_at)) as average
from bigquery-public-data.thelook_ecommerce.order_items
where FORMAT_DATE('%Y-%m',created_at) > '2019-01' and FORMAT_DATE('%Y-%m',created_at) <'2022-04'

----em dùng lệnh 'avg(sale_price) over (partition by extract(month from created_at) )' thay cho câu sum được ko ạ
-----3-------------
CREATE TEMP TABLE cust_infor_temp as (
SELECT first_name, last_name, gender, age,
  CASE WHEN age = (SELECT MIN(age) FROM bigquery-public-data.thelook_ecommerce.users WHERE created_at BETWEEN '2019-01-01' AND '2022-04-30') THEN 'youngest'
       WHEN age = (SELECT MAX(age) FROM bigquery-public-data.thelook_ecommerce.users WHERE created_at BETWEEN '2019-01-01' AND '2022-04-30') THEN 'oldest'
  END AS tag
FROM bigquery-public-data.thelook_ecommerce.users
WHERE created_at BETWEEN '2019-01-01' AND '2022-04-30'
ORDER BY age ASC)
SELECT tag, COUNT(*) AS total
FROM cust_infor_temp
GROUP BY tag;
----4--------
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
order by month_year asc, profit desc) as monthlysales
limit 5
----5--------
select 
format_date('%y-%m-%d',a.created_at), b.category as product_category,
(count(b.category) over (partition by extract (date from a.created_at)))*a.sale_price
from  bigquery-public-data.thelook_ecommerce.order_items as a 
left join bigquery-public-data.thelook_ecommerce.products as b
on a.id = b.id
----III.1------------------------
select 
month_year,product_category
tpv,round(100.00*(tpv-pre_tpv)/pre_tpv,2)||"%" as revenue_growth,
tpo,round(100.00*(tpo-pre_tpo)/pre_tpo,2)||"%" as order_growth,
TC, tpv-tc as total_profit,
round(100.00*(tpv-tc)/tc,2)||"%" as profit_to_cost_ratio
from
(select 
format_date('%y-%m',a.created_at) as month_year,
c.category as product_category,
count(b.order_id) over(partition by format_date('%y-%m',a.created_at)) as tpo,
count(b.order_id) over (ORDER BY  format_date('%y-%m',a.created_at) ROWS BETWEEN 1 PRECEDING AND 1 PRECEDING) as pre_tpo,
sum(b.sale_price) over(partition by format_date('%y-%m',a.created_at)) as tpv,
 SUM(b.sale_price) OVER (ORDER BY  format_date('%y-%m',a.created_at)    ROWS     BETWEEN 1 PRECEDING AND 1 PRECEDING) as pre_tpv,
sum(c.cost) over(partition by format_date('%y-%m',a.created_at)) as TC,
FROM bigquery-public-data.thelook_ecommerce.orders AS A 
  INNER JOIN bigquery-public-data.thelook_ecommerce.order_items AS B 
    ON A.order_id = B.order_id
  INNER JOIN bigquery-public-data.thelook_ecommerce.products as c 
    on b.id=c.id)
----III.2------------------------
