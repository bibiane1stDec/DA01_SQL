-- ex.01 - 10
with job_count as(
SELECT company_id, title, description,
count(job_id) as no_job
FROM job_listings
group by company_id, title, description)
select count (DISTINCT company_id) as duplicate_companies 
from job_count
where no_job = 2 

---ex.02
  with cte as (
SELECT category, product,
sum(spend) as total_spend 
FROM product_spend
where extract(year from transaction_date) = '2022'
and category = 'appliance'
group by product, category
order by sum(spend) desc
limit 2), 
cte2 as (
SELECT category, product,
sum(spend) as total_spend 
FROM product_spend
where extract(year from transaction_date) = '2022'
and category = 'electronics'
group by product, category
order by sum(spend) desc
limit 2)
select category, product, total_spend from cte 
UNION ALL
select category, product, total_spend from cte2

---ex.03
Select count(*)
from 
(select policy_holder_id, count(case_id) 
from callers 
group by policy_holder_id 
having count(case_id) >= 3) as call_made

---ex.04
SELECT a.page_id
FROM pages as a  
LEFT JOIN page_likes as b 
on a.page_id=b.page_id
where liked_date is null
ORDER BY a.page_id 


---ex.05
with active as (select 
user_id,
extract(month from event_date) as month
from user_actions 
where extract(month from event_date) in ('6','7') 
and extract(year from event_date) ='2022'
and event_type in ('sign-in','like', 'comment')
)
select count(DISTINCT b.user_id), b.month
from user_actions as a  
join active as b 
on a.user_id=b.user_id 
group by b.month

---ex.06
SELECT DATE_FORMAT(trans_date, '%Y-%m') AS month, 
country, 
COUNT(id) AS trans_count, 
SUM(state = 'approved') AS approved_count, 
SUM(amount) AS trans_total_amount, 
SUM(IF(state = 'approved', amount, 0)) AS approved_total_amount 
FROM Transactions 
GROUP BY month, country;
  
---ex.07
select p.product_id, s.year as first_year, s.quantity, s.price
from Product as p 
join Sales as s 
on p.product_id=s.Product_id 
where (p.product_id, s.year) in (select product_id, min(year) from sales group by product_id)

---ex.08
select customer_id 
from customer
group by customer_id
having count(product_key) = (select count(distinct product_key) from product)

---ex.09 
SELECT employee_id
FROM employees
WHERE salary < 30000 AND manager_id NOT IN (SELECT employee_id FROM employees) 
ORDER BY employee_id;

---ex.11
select  b.name 
from Movierating as a
join Users as b on a.user_id=b.user_id 
having max(a.rating)

union all 
    select c.title from Movierating as a
    join Movies as c on a.movie_id = c.movie_id 
where extract(month from created_at) = '02' and extract(year from created_at) = '2020'
group by c.title
having max(avg(a.rating))

--- ex.12
with a as (
select m.title as results from Movies m inner join (select movie_id,avg(rating) as avg_rating from MovieRating where created_at < '2020-03-01' and created_at > '2020-01-31'
    group by movie_id
    order by avg_rating desc
) x on x.movie_id = m.movie_id 
order by x.avg_rating desc , m.title asc
limit 1
), 
b as ( select u.name as results from Users u inner join (
    select user_id , count(user_id) as user_count from MovieRating 
group by user_id
) y
on u.user_id = y.user_id 
order by y.user_count desc , u.name asc
limit 1
)
select * from b
union all
select *  from a 














