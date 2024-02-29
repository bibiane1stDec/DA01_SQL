ex. 1
select b.continent, floor(avg(a.population))
from city as a
inner join country as b 
on a.countrycode and b.code 
group by b.continent

ex.2 --- đoạn này em chỉ chạy được ra là 0.00 thôi ạ, không biết đúng hay không ạ. 
SELECT 
round(cast ((count(b.email_id)/count(a.email_id))
      as decimal), 2) as confirm_rate
FROM emails as a
left join texts as b 
on a.email_id = b.email_id 
and b.signup_action = 'Confirmed'

ex.3
select b.age_bucket,
ROUND(100.0 *
sum(a.time_spent) filter (where a.activity_type ='send')/sum(a.time_spent),2) as send_perc,
ROUND(100.0 *
sum(a.time_spent) filter (where a.activity_type ='open')/sum(a.time_spent),2) as open_perc
from activities as A
inner join age_breakdown as b 
on a.user_id=b.user_id
WHERE a.activity_type IN ('send', 'open') 
GROUP BY b.age_bucket

ex.4 
select count(distinct product_category) from products --- output cho ra có 3 loại hàng
  
SELECT a.customer_id
FROM customer_contracts as a 
left join products as b 
on a.product_id= b.product_id 
group by a.customer_id
having count(DISTINCT b.product_category) = 3

ex.5 
select mng.reports_to as employee_id, 
        emp.name,
        count(mng.reports_to) as reports_count,
        round(avg(mng.age),0) as average_age
from employees as emp
join employees as mng
on emp.employee_id=mng.reports_to
group by mng.reports_to
order by mng.reports_to

ex.6 
select p.product_name, 
sum(o.unit) as unit
from products as p
left join orders as o
on p.product_id = o.product_id 
where extract(month from o.order_date) = '02' and extract(year from o.order_date) ='2020'
group by p.product_name
having sum(o.unit) >= 100

ex.07
SELECT a.page_id
FROM pages as a  
LEFT JOIN page_likes as b 
on a.page_id=b.page_id
where liked_date is null
ORDER BY a.page_id 











