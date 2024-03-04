-------- ex.01 - 10----------------------------------------------------------------------------------------
with job_count as(
SELECT company_id, title, description,
count(job_id) as no_job
FROM job_listings
group by company_id, title, description)
select count (DISTINCT company_id) as duplicate_companies 
from job_count
where no_job = 2 
------------------------------------------
SELECT count(a.company_id) AS duplicate_companies -- đếm số job trùng  
FROM (
	SELECT company_id
		,title
		,description
		,count(job_id)
	FROM job_listings -- dùng subquery để lấy ra các job trùng 
	GROUP BY company_id
		,title
		,description
	HAVING count(job_id) > 1
	) AS a;

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
having count(case_id) >= 3) as call_made'

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

/*--------------------------------------------------------EX1 --------------------------------------------------------------------------*/
SELECT count(a.company_id) AS duplicate_companies -- đếm số job trùng  
FROM (
	SELECT company_id
		,title
		,description
		,count(job_id)
	FROM job_listings -- dùng subquery để lấy ra các job trùng 
	GROUP BY company_id
		,title
		,description
	HAVING count(job_id) > 1
	) AS a;



/*--------------------------------------------------------EX2 --------------------------------------------------------------------------*/
WITH total_spend1
AS (
	SELECT category
		,product
		,sum(spend) AS total_spend
	FROM product_spend
	WHERE category = 'appliance'
		AND EXTRACT(year FROM transaction_date) = '2022'
	GROUP BY product
		,category
	ORDER BY total_spend DESC limit 2
	)
	,-- lấy tổng số tiền sản phẩm từ danh mục appliance 
total_spend2
AS (
	SELECT category
		,product
		,sum(spend) AS total_spend
	FROM product_spend
	WHERE category = 'electronics'
		AND EXTRACT(year FROM transaction_date) = '2022'
	GROUP BY product
		,category
	ORDER BY total_spend DESC limit 2
	) -- lấy tổng số tiền sản phẩm từ danh mục electronics
SELECT *
FROM total_spend1
UNION ALL
SELECT *
FROM total_spend2
	--nối 2 bảng lại với nhau

	--- cách 2 
WITH top_product AS
(SELECT product, SUM(spend) AS total_spend
FROM product_spend
WHERE EXTRACT(year FROM transaction_date) = '2022' 
GROUP BY product
ORDER BY total_spend DESC
LIMIT 4)

SELECT A.category, top_product.product, top_product.total_spend 
FROM product_spend AS A
JOIN top_product
ON A.PRODUCT = top_product.PRODUCT
GROUP BY A.category, top_product.product, top_product.total_spend 
ORDER BY category, TOTAL_SPEND DESC
/*--------------------EX3--------------------------------------------------------------------------*/	
	WITH cte
AS (
	SELECT policy_holder_id
		,count(*)
	FROM callers
	GROUP BY policy_holder_id
	HAVING count(*) >= 3
	)
SELECT count(*)
FROM cte
/*--------------------------------------------------------EX4--------------------------------------------------------------------------*/
SELECT p.page_id
FROM pages AS p
LEFT JOIN page_likes AS pl ON p.page_id = pl.page_id
WHERE pl.user_id IS NULL
ORDER BY p.page_id
 /*--------------------------------------------------------EX5--------------------------------------------------------------------------*/ 
WITH current_month
AS (
	SELECT EXTRACT(month FROM event_date) AS curr_month
	FROM user_actions
	ORDER BY EXTRACT(month FROM event_date) DESC limit 1
	)
	,-- lấy ra tháng hiện tại 
before_month
AS (
	SELECT EXTRACT(month FROM event_date) - 1 AS bef_month
	FROM user_actions
	ORDER BY EXTRACT(month FROM event_date) DESC limit 1
	)
	,-- lấy ra tháng trước
user_active_current_month
AS (
	SELECT DISTINCT user_id
	FROM user_actions
	WHERE EXTRACT(month FROM event_date) = (
			SELECT curr_month
			FROM current_month
			)
	)
	,-- lấy ra user hoạt động tháng này
user_active_before_month
AS (
	SELECT DISTINCT user_id
	FROM user_actions
	WHERE EXTRACT(month FROM event_date) = (
			SELECT bef_month
			FROM before_month
			)
	) -- lấy ra user hoạt động tháng trước 
SELECT (
		SELECT curr_month
		FROM current_month
		) AS month
	,count(*) AS monthly_active_users
FROM user_active_current_month AS a
JOIN user_active_before_month AS b ON a.user_id = b.user_id
 /*--------------------------------------------------------EX6--------------------------------------------------------------------------*/ 
	
	select  DATE_FORMAT(trans_date, '%Y-%m') AS month,
country, count(*) as  trans_count ,
sum( case when state ='approved 'then 1 else 0 end) as approved_count,
sum( amount) as trans_total_amount,
sum( case when state ='approved 'then amount else 0 end) as approved_total_amount 
from Transactions
group by month,
country 

 /*--------------------------------------------------------EX7--------------------------------------------------------------------------*/ 

WITH min_year
AS (
	SELECT product_id
		,min(year) AS minyear
	FROM Sales
	GROUP BY product_id
	)
SELECT a.product_id
	,a.year AS first_year
	,a.quantity
	,a.price
FROM Sales AS a
JOIN min_year AS b ON a.product_id = b.product_id
WHERE b.minyear = a.year

/*--------------------------------------------------------EX8--------------------------------------------------------------------------*/ 
WITH cte
AS (
	SELECT customer_id
		,product_key
	FROM Customer
	GROUP BY customer_id
		,product_key
	)
SELECT customer_id
FROM cte
GROUP BY customer_id
HAVING count(*) = (
		SELECT count(DISTINCT product_key)
		FROM Product
		)
ORDER BY customer_id
/*--------------------------------------------------------EX9--------------------------------------------------------------------------*/ 
SELECT employee_id
FROM Employees
WHERE salary < 30000
	AND manager_id NOT IN (
		SELECT employee_id
		FROM Employees
		)
ORDER BY employee_id
/*--------------------------------------------------------EX10 trùng EX 1--------------------------------------------------------------------------*/ 
/*--------------------------------------------------------EX11 --------------------------------------------------------------------------*/
-- Write your PostgreSQL query statement below
WITH cte
AS (
	SELECT a.name AS results
	FROM Users AS a
	JOIN MovieRating AS b ON a.user_id = b.user_id
	GROUP BY a.name
	ORDER BY count(*) DESC
		,a.name limit 1
	)
	,cte2
AS (
	SELECT c.title AS results
	FROM Movies AS c
	JOIN MovieRating AS d ON c.movie_id = d.movie_id
	WHERE extract(month FROM d.created_at) = 2
		AND extract(year FROM d.created_at) = 2020
	GROUP BY c.title
	ORDER BY avg(rating) DESC
		,c.title limit 1
	)
SELECT *
FROM cte

UNION ALL

SELECT *
FROM cte2
/*--------------------------------------------------------EX12 --------------------------------------------------------------------------*/
WITH cte
AS (
	SELECT requester_id AS id
		,count(*) AS count
	FROM RequestAccepted
	GROUP BY requester_id
	)
	,cte1
AS (
	SELECT accepter_id AS id
		,count(*) AS count
	FROM RequestAccepted
	GROUP BY accepter_id
	)
SELECT id
	,sum(count) AS num
FROM (
	SELECT *
	FROM cte
	
	UNION ALL
	
	SELECT *
	FROM cte1
	)
GROUP BY id
ORDER BY num DESC limit 1











