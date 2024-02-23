--- EX. 1
SELECT DISTINCT CITY FROM STATION 
WHERE ID%2=0

--- EX. 2
SELECT COUNT(CITY) - COUNT(DISTINCT CITY)
FROM STATION

/* EX. 3 
round it up to the next integer = CEILING
REPLACE(SALARY,0,''): THAY THẾ MỘT CHUỖI NHỎ/KÝ TỰ TRONG MỘT CHUỖI LỚN BẰNG CHUỐI/KÝ TỰ KHÁC*/ 
  
SELECT 
CEILING(AVG(SALARY)- AVG(REPLACE(SALARY,0,'')))
FROM EMPLOYEES

--- EX. 4: 
  RULE: INT/INT=INT 
SELECT 
ROUND(CAST((SUM(ITEM_COUNT*ORDER_OCCURRENCES)/SUM(ORDER_OCCURRENCES)) AS DECIMAL),1) AS MEAN
FROM items_per_order

--- EX. 5 
SELECT CANDIDATE_ID FROM candidates
WHERE SKILL IN ('Python', 'Tableau', 'PostgreSQL')
group by candidate_id
HAVING COUNT(skill)=3

--- EX. 6
SELECT user_id,
max(date(post_date)) - min(date(post_date)) as days_between
FROM posts
where post_date between '01/01/2021' and '01/01/2022'
group by user_id 
having count(user_id) >1

--- EX. 7 
SELECT card_name,
max(issued_amount)-min(issued_amount) as DIFFERENCE
FROM monthly_cards_issued
group by card_name
order by max(issued_amount)-min(issued_amount) desc

--- EX. 8 
SELECT MANUFACTURER, 
abs(sum(TOTAL_SALES-COGS)) AS total_loss,
count(drug) as drug_count
FROM pharmacy_sales
WHERE TOTAL_SALES-COGS <0
group by manufacturer 
order by total_loss desc

--- EX. 9 
SELECT * FROM CINEMA
WHERE ID%2=1 AND DESCRIPTION <> 'boring' --- trích từ trong ngoặc thì viết hoa/thường phải đúng 
ORDER BY RATING DESC

--- EX. 10
select teacher_id,
count(distinct subject_id) as CNT
from TEACHER
GROUP BY teacher_id

--- EX. 11
SELECT USER_ID,
COUNT(FOLLOWER_ID) AS FOLLOWERS_COUNT
FROM FOLLOWERS
GROUP BY USER_ID
ORDER BY USER_ID

--- EX. 12 -- (TRONG SELECT LÀ NHỮNG GÌ HIỆN TRÊN OUTPUT TABLE)
SELECT CLASS
FROM COURSES 
GROUP BY CLASS
HAVING COUNT(STUDENT) >= 5













