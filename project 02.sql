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




