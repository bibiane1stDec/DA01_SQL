--- ex. 01
SELECT 
sum (CASE 
  WHEN DEVICE_TYPE = 'laptop' then 1 
  else 0
end) as laptop_views,
sum (case
 WHEN DEVICE_TYPE in ('tablet','phone') then 1
 else 0
end) as mobile_views
FROM viewership

--- ex. 02 
select
x, y, z,
case 
    when x + y > z and x + z > y and y + z > x  then 'Yes'
    else 'No'
end as triangle 
from triangle

--- Ex. 03
SELECT 
round (100.0 *sum(case 
  when call_category is null or call_category = 'n/a' then 1
  else 0 end)/
count(*), 1) as call_percentage
FROM callers

--- ex. 04 
SELECT name FROM CUSTOMER 
WHERE REFEREE_ID <> 2 OR REFEREE_ID is null;

---- ex. 05
SELECT
    survived,
    sum(CASE WHEN pclass = 1 THEN 1 ELSE 0 END) AS first_class,
    sum(CASE WHEN pclass = 2 THEN 1 ELSE 0 END) AS second_class,
    sum(CASE WHEN pclass = 3 THEN 1 ELSE 0 END) AS third_class
FROM titanic
GROUP BY 
    survived



