---EX. 1 
SELECT NAME FROM CITY
WHERE POPULATION > 120000 AND COUNTRYCODE = 'USA';

---EX. 2
SELECT * FROM CITY 
WHERE COUNTRYCODE = 'JPN';

---Ex. 3
SELECT CITY, STATE FROM STATION;

---Ex. 4 (CÓ CÁCH NÀO ĐỂ GIẢI BÀI NÀY NHANH HƠN ĐƯỢC KO Ạ)
SELECT DISTINCT CITY FROM STATION
WHERE CITY LIKE 'A%' OR CITY LIKE 'E%' OR CITY LIKE 'I%' OR CITY LIKE 'O%' OR CITY LIKE 'U%';

---Ex. 5 
SELECT DISTINCT CITY FROM STATION
WHERE CITY LIKE '%A' OR CITY LIKE '%E' OR CITY LIKE '%I' OR CITY LIKE '%O' OR CITY LIKE '%U';

--- Ex. 6 
SELECT DISTINCT CITY FROM STATION
WHERE NOT (CITY LIKE 'A%' OR CITY LIKE 'E%' OR CITY LIKE 'I%' OR CITY LIKE 'O%' OR CITY LIKE 'U%');

--- Ex. 7 
SELECT NAME FROM EMPLOYEE
ORDER BY NAME;

--- Ex. 8
SELECT NAME FROM EMPLOYEE
WHERE SALARY >2000 AND MONTHS <10 
ORDER BY EMPLOYEE_ID;

--- Ex. 9 
SELECT PRODUCT_ID FROM PRODUCTS 
WHERE LOW_FATS = 'Y' AND RECYCLABLE = 'Y';

--- Ex. 10 
SELECT name FROM CUSTOMER 
WHERE REFEREE_ID <> 2 OR REFEREE_ID is null;

--- Ex. 11
SELECT NAME, POPULATION, AREA FROM WORLD
WHERE AREA >= 3000000 OR POPULATION >= 25000000;

--- Ex. 12 (cái này e tự mò ra, cơ mà em vẫn chưa hiểu đoạn tại sao là lệnh select distinct, trong bảng input, em thấy có số 4 là xem 2 lần trong cùng 1 ngày ạ) 
SELECT DISTINCT AUTHOR_ID AS ID FROM VIEWS
WHERE AUTHOR_ID = VIEWER_ID;

--- Ex. 13 
SELECT PART, ASSEMBLY_STEP FROM parts_assembly
WHERE finish_date IS NULL;

--- Ex. 14 
select * from lyft_drivers
where not yearly_salary between 30000 and 70000;

--- Ex. 15 
select advertising_channel from uber_advertising
where money_spent > 100000 and year = 2019;









