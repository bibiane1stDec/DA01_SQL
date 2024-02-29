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

--------------------------------------------------------------------------------------
mid-course
--- ex 01
      select distinct replacement_cost
from film 
order by replacement_cost 

---ex. 2
select 
SUM(case 
	when replacement_cost between 9.99 and 19.99 then 1 ELSE 0
	END) AS LOW, 
SUM(CASE	
	WHEN replacement_cost between 20.00 and 24.99 THEN 1 ELSE 0
	END) AS MEDIUM,
SUM(CASE	
	WHEN replacement_cost between 25.00 and 29.99 THEN 1 ELSE 0
	END) AS HIGH
from film

--- EX. 3 
SELECT a.title, a.length, c. name as category_name
FROM FILM as a 
JOIN public.film_category as b on a.film_id=b.film_id
join public.category as c on b.category_id=c.category_id
where c.name in ('Drama', 'Sports')
order by a.length desc

-- Ex. 4 
SELECT c.name as category_name,
COUNT(a.title)
FROM FILM as a 
JOIN public.film_category as b on a.film_id=b.film_id
join public.category as c on b.category_id=c.category_id
group by c.name
order by count(a.title) desc

/* ex. 5: 
bài này em ko ra đáp án là 54, vì susan davis có hai id khác nhau 
nghĩa là 2 người khác nhau... 
*/
select a.actor_id, a.first_name, a.last_name,
count(f.film_id)
from actor as a 
join film_actor as f
on a.actor_id=f.actor_id 
group by a.actor_id 
order by count(f.film_id) desc

---ex. 6 
select a.address_id,
a.address,
from address as a
left join customer as c  
on a.address_id = c.address_id 
where c.customer_id is null

select count(a.address_id)
from address as a
left join customer as c  
on a.address_id = c.address_id 
where c.customer_id is null

--- ex. 7 
Select c.city,
sum(d.amount)
from customer as a 
join address as b on a.address_id=b.address_id 
join city as c on b.city_id= c.city_id
join payment as d on a.customer_id= d.customer_id 
where c.city= 'Tallahassee'
group by c.city 
order by sum(d.amount) desc

---ex. 8
Select c.city, e.country,
sum(d.amount)
from customer as a 
join address as b on a.address_id=b.address_id 
join city as c on b.city_id= c.city_id
join payment as d on a.customer_id= d.customer_id 
join country as e on c.country_id= e.country_id
group by c.city , e.country
order by sum(d.amount) desc

