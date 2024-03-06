----------------------ex.1------------------
with immediate as (
select customer_id,
min(order_date) as first_order
from Delivery
where order_date =customer_pref_delivery_date
group by customer_id)
select 
count(b.first_order)/
count(distinct a.customer_id) as immediate_percentage
from Delivery as a
left join immediate as b on a.customer_id=b.customer_id

----------------------ex.2------------------
select
round(
  100*sum(
        case when st_order = st_deli then 1 else 0 end)/count(*),2  ) as immediate_percentage
from (
SELECT MIN(order_date) AS st_order, MIN(customer_pref_delivery_date) AS st_deli 
    FROM Delivery 
    GROUP BY customer_id) as min_deli

----------------------ex.3------------------
select 
case 
    when id = (select max(id) from seat) and id%2=1 then id
    when id%2=1 then id+1
    else id-1   
end as new_seat,
student 
from seat 
order by new_seat
----------------------ex.4------------------
----------------------ex.5------------------
select 
round(sum(tiv_2016),2) as tiv_2016
from Insurance
where tiv_2015 in (
    select 
        tiv_2015 from Insurance
        group by tiv_2015
        having count(tiv_2015) > 1)
and 
        (lat, lon) in (select 
        lat, lon from Insurance
        group by lat, lon
        having count(*) =1 
    )
----------------------ex.6------------------
----------------------ex.7------------------
select
person_name from ( 
select 
person_name, 
sum(weight) over (order by turn) as acc_weight
from queue) as total_weight
where acc_weight <= 1000 
----------------------ex.8------------------
select distinct product_id,
10 as new_price 
from products where 
product_id not in 
(select distinct product_id from Products where change_date <='2019-08-16' )
union 
select product_id, new_price 
from products
where (product_id, change_date) in 
(select product_id, 
max(change_date) as new_date 
from Products
where change_date <= '2019-08-16'
group by product_id)










